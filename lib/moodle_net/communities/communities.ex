# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Communities do
  alias Ecto.Changeset
  alias MoodleNet.{
    Activities,
    Actors,
    Blocks,
    Collections,
    Common,
    Features,
    Feeds,
    Flags,
    Follows,
    Likes,
    Repo,
    Threads,
  }
  alias MoodleNet.Communities.{Community, Queries}
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Users.User
  alias MoodleNet.Workers.APPublishWorker

  ### Cursor generators

  def cursor(:followers), do: &[&1.follower_count, &1.id]

  def test_cursor(:followers), do: &[&1["followerCount"], &1["id"]]

  ### Queries

  @doc "Retrieves a single community by arbitrary filters."
  def one(filters), do: Repo.single(Queries.query(Community, filters))

  @doc "Retrieves a list of communities by arbitrary filters."
  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Community, filters))}

  ### Mutations

  @spec create(User.t(), attrs :: map) :: {:ok, Community.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %{} = attrs) do
    Repo.transact_with(fn ->
      with {:ok, actor} <- Actors.create(attrs),
           {:ok, comm_attrs} <- create_boxes(actor, attrs),
           {:ok, comm} <- insert_community(creator, actor, comm_attrs),
           act_attrs = %{verb: "created", is_local: is_nil(actor.peer_id)},
           {:ok, activity} <- Activities.create(creator, comm, act_attrs),
           {:ok, _follow} <- Follows.create(creator, comm, %{is_local: true}),
           :ok <- publish(creator, comm, activity),
           :ok <- ap_publish("create", comm) do
        {:ok, comm}
      end
    end)
  end

  defp create_boxes(%{peer_id: nil}, attrs), do: create_local_boxes(attrs)
  defp create_boxes(%{peer_id: _}, attrs), do: create_remote_boxes(attrs)

  defp create_local_boxes(attrs) do
    with {:ok, inbox} <- Feeds.create(),
         {:ok, outbox} <- Feeds.create() do
      extra = %{inbox_id: inbox.id, outbox_id: outbox.id}
      {:ok, Map.merge(attrs, extra)}
    end
  end

  defp create_remote_boxes(attrs) do
    with {:ok, outbox} <- Feeds.create() do
      {:ok, Map.put(attrs, :outbox_id, outbox.id)}
    end
  end

  defp insert_community(creator, actor, attrs) do
    with {:ok, community} <- Repo.insert(Community.create_changeset(creator, actor, attrs)) do
      {:ok, %{ community | actor: actor }}
    end
  end

  @spec update(User.t(), %Community{}, attrs :: map) :: {:ok, Community.t()} | {:error, Changeset.t()}
  def update(%User{}=user, %Community{} = community, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      with {:ok, comm} <- Repo.update(Community.update_changeset(community, attrs)),
           {:ok, actor} <- Actors.update(user, community.actor, attrs),
           community <- %{ comm | actor: actor },
           :ok <- ap_publish("update", community) do
        {:ok, community}
      end
    end)
  end

  def update_by(%User{}, filters, updates) do
    Repo.update_all(Queries.query(Community, filters), set: updates)
  end

  def soft_delete(%User{}=user, %Community{} = community) do
    Repo.transact_with(fn ->
      with {:ok, community} <- Common.soft_delete(community),
           %{community: comms, feed: feeds} = deleted_ids([community]),
           :ok <- chase_delete(user, comms, feeds),
           :ok <- ap_publish("delete", community) do
        {:ok, community}
      end
    end)
  end

  def soft_delete_by(%User{}=user, filters) do
    with {:ok, _} <-
      Repo.transact_with(fn ->
        {_, ids} = update_by(user, [{:select, :delete} | filters], deleted_at: DateTime.utc_now())
        %{community: community, feed: feed} = deleted_ids(ids)
        chase_delete(user, community, feed)
      end), do: :ok
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

  defp chase_delete(user, communities) do
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

  defp chase_delete(user, communities, []), do: chase_delete(user, communities)
  defp chase_delete(user, communities, feeds) do
    with :ok <- Feeds.soft_delete_by(user, id: feeds), do: chase_delete(user, communities)
  end

  # defp default_inbox_query_contexts() do
  #   Application.fetch_env!(:moodle_net, __MODULE__)
  #   |> Keyword.fetch!(:default_inbox_query_contexts)
  # end

  @doc false
  def default_outbox_query_contexts() do
    Application.fetch_env!(:moodle_net, __MODULE__)
    |> Keyword.fetch!(:default_outbox_query_contexts)
  end

  # Feeds
  defp publish(creator, community, activity) do
    feeds = [community.outbox_id, creator.outbox_id, Feeds.instance_outbox_id()]
    FeedActivities.publish(activity, feeds)
  end

  defp ap_publish(%{actor: %{peer_id: nil}} = community, verb) do
    APPublishWorker.enqueue(verb, %{"context_id" => community.id})
    :ok
  end

  defp ap_publish(_, _), do: :ok

end
