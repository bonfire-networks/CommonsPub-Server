# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Communities do
  alias Ecto.Changeset
  alias MoodleNet.{Activities, Actors, Common, Feeds, Follows, Repo}
  alias MoodleNet.Communities.{Community, Queries}
  alias MoodleNet.FeedPublisher
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Users.User

  ### Cursor generators

  def cursor(:followers), do: &[&1.follower_count, &1.id]

  def test_cursor(:followers), do: &[&1["followerCount"], &1["id"]]

  ### Queries

  @doc """
  Retrieves a single community by arbitrary filters.
  Used by:
  * GraphQL Item queries
  * ActivityPub integration
  * Various parts of the codebase that need to query for communities (inc. tests)
  """
  def one(filters), do: Repo.single(Queries.query(Community, filters))

  @doc """
  Retrieves a list of communities by arbitrary filters.
  Used by:
  * Various parts of the codebase that need to query for communities (inc. tests)
  """
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
           :ok <- publish(creator, comm, activity, :created),
           :ok <- ap_publish(creator, comm) do
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

  @spec update(%Community{}, attrs :: map) :: {:ok, Community.t()} | {:error, Changeset.t()}
  def update(%Community{} = community, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      with {:ok, comm} <- Repo.update(Community.update_changeset(community, attrs)),
           {:ok, actor} <- Actors.update(community.actor, attrs),
           community <- %{ comm | actor: actor },
           :ok <- publish(community, :updated),
           :ok <- ap_publish(community) do 
        {:ok, community}
      end
    end)
  end

  def soft_delete(%Community{} = community) do
    Repo.transact_with(fn ->
      with {:ok, community} <- Common.soft_delete(community),
           :ok <- publish(community, :deleted),
           :ok <- ap_publish(community) do
        {:ok, community}
      end
    end)
  end

  def soft_delete_by(filters) do
    Queries.query(Community)
    |> Queries.filter(filters)
    |> Repo.delete_all()
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
  defp publish(creator, community, activity, :created) do
    feeds = [community.outbox_id, creator.outbox_id, Feeds.instance_outbox_id()]
    FeedActivities.publish(activity, feeds)
  end
  defp publish(_community, :updated), do: :ok
  defp publish(community, :deleted) do
    # Activities
    :ok
  end

  

  ### HACK FIXME
  defp ap_publish(%{creator_id: id}=community), do: ap_publish(%{id: id}, community)

  defp ap_publish(user, %{actor: %{peer_id: nil}}=community) do
    FeedPublisher.publish(%{ "context_id" => community.id, "user_id" => user.id })
  end
  defp ap_publish(_, _), do: :ok

end
