# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Collections do
  import ProtocolEx
  alias MoodleNet.{Activities, Actors, Common, Feeds, Follows, Repo}
  alias MoodleNet.Collections.{Collection,  Queries}
  alias MoodleNet.Communities.Community
  alias MoodleNet.FeedPublisher
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Meta.Pointable
  alias MoodleNet.Users.User

  def cursor(:followers), do: &[&1.follower_count, &1.id]

  def test_cursor(:followers), do: &[&1["followerCount"], &1["id"]]

  @doc """
  Retrieves a single collection by arbitrary filters.
  Used by:
  * GraphQL Item queries
  * ActivityPub integration
  * Various parts of the codebase that need to query for collections (inc. tests)
  """
  def one(filters), do: Repo.single(Queries.query(Collection, filters))

  @doc """
  Retrieves a list of collections by arbitrary filters.
  Used by:
  * Various parts of the codebase that need to query for collections (inc. tests)
  """
  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Collection, filters))}

  ## mutations
  defp prepend_comm_username(%{actor: %{preferred_username: comm_username}}, %{preferred_username: coll_username}) do
    comm_username <> coll_username
  end

  defp prepend_comm_username(_community, _attr), do: nil

  @spec create(User.t(), Community.t(), attrs :: map) :: {:ok, Collection.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %Community{} = community, attrs) when is_map(attrs) do
    # preferred_username = prepend_comm_username(community, attrs)
    # attrs = Map.put(attrs, :preferred_username, preferred_username)

    Repo.transact_with(fn ->
      with {:ok, actor} <- Actors.create(attrs),
           {:ok, coll_attrs} <- create_boxes(actor, attrs),
           {:ok, coll} <- insert_collection(creator, community, actor, coll_attrs),
           act_attrs = %{verb: "created", is_local: true},
           {:ok, activity} <- Activities.create(creator, coll, act_attrs),
           :ok <- publish(creator, community, coll, activity, :created),
           :ok <- ap_publish(creator, coll),
           {:ok, _follow} <- Follows.create(creator, coll, %{is_local: true}) do
        {:ok, coll}
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

  defp insert_collection(creator, community, actor, attrs) do
    cs = Collection.create_changeset(creator, community, actor, attrs)
    with {:ok, coll} <- Repo.insert(cs), do: {:ok, %{ coll | actor: actor }}
  end

  defp publish(creator, community, collection, activity, :created) do
    feeds = [
      community.outbox_id, creator.outbox_id,
      collection.outbox_id, Feeds.instance_outbox_id(),
    ]
    FeedActivities.publish(activity, feeds)
  end
  defp publish(collection, :updated), do: :ok
  defp publish(collection, :deleted), do: :ok

  ### HACK FIXME
  defp ap_publish(%{creator_id: id}=collection), do: ap_publish(%{id: id}, collection)

  defp ap_publish(user, %{actor: %{peer_id: nil}}=collection) do
    FeedPublisher.publish(%{"context_id" => collection.id, "user_id" => user.id})
  end
  defp ap_publish(_, _), do: :ok

  # TODO: take the user who is performing the update
  @spec update(%Collection{}, attrs :: map) :: {:ok, Collection.t()} | {:error, Changeset.t()}
  def update(%Collection{} = collection, attrs) do
    Repo.transact_with(fn ->
      collection = Repo.preload(collection, :community)
      with {:ok, collection} <- Repo.update(Collection.update_changeset(collection, attrs)),
           {:ok, actor} <- Actors.update(collection.actor, attrs),
           collection = %{collection | actor: actor},
           :ok <- publish(collection, :updated),
           :ok <- ap_publish(collection) do
        {:ok, collection}
      end
    end)
  end

  def soft_delete(%Collection{} = collection) do
    Repo.transact_with(fn ->
      with {:ok, collection} <- Common.soft_delete(collection),
           :ok <- publish(collection, :deleted),
           :ok <- ap_publish(collection) do 
        {:ok, collection}
      end
    end)
  end

  def soft_delete(%Collection{} = collection) do
    Repo.transact_with(fn ->
      with {:ok, collection} <- Common.soft_delete(collection),
           :ok <- publish(collection, :deleted),
           :ok <- ap_publish(collection) do 
        {:ok, collection}
      end
    end)
  end

  def soft_delete_by(filters) do
    Queries.query(Collection)
    |> Queries.filter(filters)
    |> Repo.delete_all()
  end

  @doc false
  def default_outbox_query_contexts() do
    Application.fetch_env!(:moodle_net, __MODULE__)
    |> Keyword.fetch!(:default_outbox_query_contexts)
  end

  defimpl_ex CollectionPointable, Collection, for: Pointable do
    def queries_module(_), do: Queries
    def extra_filters(_), do: [:default]
  end

end
