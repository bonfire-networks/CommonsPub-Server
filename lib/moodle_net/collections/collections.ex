# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Collections do
  alias MoodleNet.{
    Activities,
    Actors,
    Blocks,
    Common,
    Features,
    FeedPublisher,
    Feeds,
    Flags,
    Follows,
    Likes,
    Repo,
    Resources,
    Threads,
  }
  alias MoodleNet.Collections.{Collection,  Queries}
  alias MoodleNet.Communities.Community
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Users.User

  def cursor(:followers), do: &[&1.follower_count, &1.id]

  def test_cursor(:followers), do: &[&1["followerCount"], &1["id"]]

  @doc "Retrieves a single collection by arbitrary filters."
  def one(filters), do: Repo.single(Queries.query(Collection, filters))

  @doc "Retrieves a list of collections by arbitrary filters."
  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Collection, filters))}

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
           :ok <- publish(creator, community, coll, activity),
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

  # TODO: take the user who is performing the update
  @spec update(User.t(), %Collection{}, attrs :: map) :: {:ok, Collection.t()} | {:error, Changeset.t()}
  def update(%User{}=user, %Collection{} = collection, attrs) do
    Repo.transact_with(fn ->
      collection = Repo.preload(collection, :community)
      with {:ok, collection} <- Repo.update(Collection.update_changeset(collection, attrs)),
           {:ok, actor} <- Actors.update(user, collection.actor, attrs),
           collection = %{collection | actor: actor},
           :ok <- ap_publish(collection) do
        {:ok, collection}
      end
    end)
  end

  def update_by(%User{}, filters, updates) do
    Repo.update_all(Queries.query(Collection, filters), set: updates)
  end

  def soft_delete(%User{}=user, %Collection{} = collection) do
    Repo.transact_with(fn ->
      with {:ok, collection} <- Common.soft_delete(collection),
           %{collection: colls, feed: feeds} = deleted_ids([collection]),
           :ok <- chase_delete(user, colls, feeds),
           :ok <- ap_publish(collection) do 
        {:ok, collection}
      end
    end)
  end

  def soft_delete_by(%User{}=user, filters) do
    with {:ok, _} <-
      Repo.transact_with(fn ->
        {_, ids} = update_by(user, [{:select, :delete} | filters], deleted_at: DateTime.utc_now())
        %{collection: collection, feed: feed} = deleted_ids(ids)
        chase_delete(user, collection, feed)
      end), do: :ok
  end

  defp deleted_ids(records) do
    Enum.reduce(records, %{collection: [], feed: []}, fn
      %{id: id, inbox_id: nil, outbox_id: nil}, acc ->
        Map.put(acc, :collection, [id | acc.collection])
      %{id: id, inbox_id: nil, outbox_id: o}, acc ->
        Map.merge(acc, %{collection: [id | acc.collection], feed: [o | acc.feed]})
      %{id: id, inbox_id: i, outbox_id: nil}, acc ->
        Map.merge(acc, %{collection: [id | acc.collection], feed: [i | acc.feed]})
      %{id: id, inbox_id: i, outbox_id: o}, acc ->
        Map.merge(acc, %{collection: [id | acc.collection], feed: [i, o | acc.feed]})
    end)
  end

  defp chase_delete(user, collections) do
    with :ok <- Activities.soft_delete_by(user, context: collections),
         :ok <- Blocks.soft_delete_by(user, context: collections),
         :ok <- Features.soft_delete_by(user, context: collections),
         :ok <- Flags.soft_delete_by(user, context: collections),
         :ok <- Follows.soft_delete_by(user, context: collections),
         :ok <- Likes.soft_delete_by(user, context: collections),
         :ok <- Resources.soft_delete_by(user, collection: collections),
         :ok <- Threads.soft_delete_by(user, context: collections) do
      :ok
    end
  end

  defp chase_delete(user, collections, []), do: chase_delete(user, collections)
  defp chase_delete(user, collections, feeds) do
    with :ok <- Feeds.soft_delete_by(user, id: feeds), do: chase_delete(user, collections)
  end

  @doc false
  def default_outbox_query_contexts() do
    Application.fetch_env!(:moodle_net, __MODULE__)
    |> Keyword.fetch!(:default_outbox_query_contexts)
  end

  defp publish(creator, community, collection, activity) do
    feeds = [
      community.outbox_id, creator.outbox_id,
      collection.outbox_id, Feeds.instance_outbox_id(),
    ]
    FeedActivities.publish(activity, feeds)
  end

  ### HACK FIXME
  defp ap_publish(%{creator_id: id}=collection), do: ap_publish(%{id: id}, collection)

  defp ap_publish(user, %{actor: %{peer_id: nil}}=collection) do
    FeedPublisher.publish(%{"context_id" => collection.id, "user_id" => user.id})
  end
  defp ap_publish(_, _), do: :ok

end
