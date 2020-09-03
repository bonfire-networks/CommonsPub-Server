# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Communities do
  alias Ecto.Changeset

  alias CommonsPub.{
    Activities,
    Blocks,
    Collections,
    Common,
    Features,
    Feeds,
    Flags,
    Follows,
    Likes,
    Repo,
    Threads
  }

  alias CommonsPub.Characters

  alias CommonsPub.Communities.{Community, Queries}
  # alias CommonsPub.FeedPublisher
  alias CommonsPub.Feeds.FeedActivities
  alias CommonsPub.Users.User
  alias CommonsPub.Workers.APPublishWorker

  ### Cursor generators

  def cursor(:followers), do: &[&1.follower_count, &1.id]

  def test_cursor(:followers), do: &[&1["followerCount"], &1["id"]]

  ### Queries

  @doc "Retrieves a single community by arbitrary filters."
  def one(filters), do: Repo.single(Queries.query(Community, filters))

  def get(username) do
    with {:ok, c} <- one([:default, username: username]) do
      c
    end
  end

  @doc "Retrieves a list of communities by arbitrary filters."
  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Community, filters))}

  ### Mutations

  def create(%User{} = creator, %{} = community_or_context, %{} = attrs) do
    Repo.transact_with(fn ->
      # TODO: address activity to context's outbox/followers
      community_or_context =
        CommonsPub.Utils.Web.CommonHelper.maybe_preload(community_or_context, :character)

      # with {:ok, comm_attrs} <- create_boxes(character, attrs),
      with {:ok, comm} <- insert_community(creator, community_or_context, attrs),
           {:ok, character} <- Characters.create(attrs),
           #  {:ok, _follow} <- Follows.create(creator, comm, %{is_local: true}),
           act_attrs = %{verb: "created", is_local: is_nil(character.peer_id)},
           {:ok, activity} <- Activities.create(creator, comm, act_attrs),
           :ok <- publish(creator, community_or_context, comm, activity),
           :ok <- ap_publish("create", comm) do
        CommonsPub.Search.Indexer.maybe_index_object(comm)
        {:ok, %{comm | character: character}}
      end
    end)
  end

  @spec create(User.t(), attrs :: map) :: {:ok, Community.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %{} = attrs) do
    Repo.transact_with(fn ->
      with {:ok, comm} <- insert_community(creator, attrs),
           {:ok, character} <- Characters.create(creator, attrs, comm),
           #  {:ok, _follow} <- Follows.create(creator, comm, %{is_local: true}),
           act_attrs = %{verb: "created", is_local: is_nil(character.peer_id)},
           {:ok, activity} <- Activities.create(creator, comm, act_attrs),
           :ok <- publish(creator, comm, activity),
           :ok <- ap_publish("create", comm) do
        CommonsPub.Search.Indexer.maybe_index_object(comm)
        {:ok, %{comm | character: character}}
      end
    end)
  end

  @spec create_remote(User.t(), attrs :: map) :: {:ok, Community.t()} | {:error, Changeset.t()}
  def create_remote(%User{} = creator, %{} = attrs) do
    Repo.transact_with(fn ->
      with {:ok, comm} <- insert_community(creator, attrs),
           {:ok, character} <- Characters.create(creator, attrs, comm),
           act_attrs = %{verb: "created", is_local: is_nil(character.peer_id)},
           {:ok, activity} <- Activities.create(creator, comm, act_attrs),
           :ok <- publish(creator, comm, activity) do
        CommonsPub.Search.Indexer.maybe_index_object(comm)
        {:ok, %{comm | character: character}}
      end
    end)
  end

  defp insert_community(creator, context, attrs) do
    with {:ok, community} <-
           Repo.insert(Community.create_changeset(creator, context, attrs)) do
      {:ok, %{community | context: context}}
    end
  end

  defp insert_community(creator, attrs) do
    with {:ok, community} <- Repo.insert(Community.create_changeset(creator, attrs)) do
      {:ok, community}
    end
  end

  @spec update(User.t(), %Community{}, attrs :: map) ::
          {:ok, Community.t()} | {:error, Changeset.t()}
  def update(%User{} = user, %Community{} = community, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      with {:ok, comm} <- Repo.update(Community.update_changeset(community, attrs)),
           {:ok, character} <- Characters.update(user, community.character, attrs),
           community <- %{comm | character: character},
           :ok <- ap_publish("update", community) do
        {:ok, community}
      end
    end)
  end

  def update_by(%User{}, filters, updates) do
    Repo.update_all(Queries.query(Community, filters), set: updates)
  end

  def soft_delete(%User{} = user, %Community{} = community) do
    Repo.transact_with(fn ->
      with {:ok, community} <- Common.soft_delete(community),
           %{community: comms, feed: feeds} = deleted_ids([community]),
           :ok <- chase_delete(user, comms, feeds),
           :ok <- ap_publish("delete", community) do
        {:ok, community}
      end
    end)
  end

  def soft_delete_by(%User{} = user, filters) do
    with {:ok, _} <-
           Repo.transact_with(fn ->
             {_, ids} =
               update_by(user, [{:deleted, false}, {:select, :delete} | filters],
                 deleted_at: DateTime.utc_now()
               )

             %{community: community, feed: feed} = deleted_ids(ids)

             with :ok <- chase_delete(user, community, feed) do
               ap_publish("delete", community)
             end
           end),
         do: :ok
  end

  defp deleted_ids(records) do
    Enum.reduce(records, %{community: [], feed: []}, fn
      %{id: id, inbox_id: nil, outbox_id: nil}, acc ->
        Map.put(acc, :community, [id | acc.community])

      %{id: id, inbox_id: nil, outbox_id: o}, acc ->
        Map.merge(acc, %{community: [id | acc.community], feed: [o | acc.feed]})

      %{id: id, inbox_id: i, outbox_id: nil}, acc ->
        Map.merge(acc, %{community: [id | acc.community], feed: [i | acc.feed]})

      %{id: id, inbox_id: i, outbox_id: o}, acc ->
        Map.merge(acc, %{community: [id | acc.community], feed: [i, o | acc.feed]})
    end)
  end

  defp chase_delete(user, communities, []) do
    with :ok <- Activities.soft_delete_by(user, context: communities),
         :ok <- Blocks.soft_delete_by(user, context: communities),
         :ok <- Collections.soft_delete_by(user, community: communities),
         :ok <- Features.soft_delete_by(user, context: communities),
         :ok <- Flags.soft_delete_by(user, context: communities),
         :ok <- Follows.soft_delete_by(user, context: communities),
         :ok <- Likes.soft_delete_by(user, context: communities),
         :ok <- Threads.soft_delete_by(user, context: communities) do
      :ok
    end
  end

  defp chase_delete(user, communities, feeds) do
    with :ok <- Feeds.soft_delete_by(user, id: feeds), do: chase_delete(user, communities, [])
  end

  # defp default_inbox_query_contexts() do
  #   CommonsPub.Config.get!(__MODULE__)
  #   |> Keyword.fetch!(:default_inbox_query_contexts)
  # end

  @doc false
  def default_outbox_query_contexts() do
    CommonsPub.Config.get!(__MODULE__)
    |> Keyword.fetch!(:default_outbox_query_contexts)
  end

  # Feeds
  defp publish(creator, community_or_context, community, activity) do
    feeds = [
      community_or_context.outbox_id,
      CommonsPub.Feeds.outbox_id(creator),
      community.outbox_id,
      Feeds.instance_outbox_id()
    ]

    FeedActivities.publish(activity, feeds)
  end

  defp publish(creator, community, activity) do
    feeds = [community.outbox_id, CommonsPub.Feeds.outbox_id(creator), Feeds.instance_outbox_id()]
    FeedActivities.publish(activity, feeds)
  end

  defp ap_publish(verb, communities) when is_list(communities) do
    APPublishWorker.batch_enqueue(verb, communities)
    :ok
  end

  defp ap_publish(verb, %{character: %{peer_id: nil}} = community) do
    APPublishWorker.enqueue(verb, %{"context_id" => community.id})
    :ok
  end

  defp ap_publish(_, _), do: :ok
end
