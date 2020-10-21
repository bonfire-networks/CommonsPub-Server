# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Collections do
  alias CommonsPub.{
    Activities,
    Blocks,
    Common,
    Features,
    Feeds,
    Flags,
    Follows,
    Likes,
    Repo,
    Resources,
    Threads
  }

  alias CommonsPub.Characters

  alias CommonsPub.Collections.{Collection, Queries}
  alias CommonsPub.Communities.Community
  # alias CommonsPub.FeedPublisher
  alias CommonsPub.Feeds.FeedActivities
  alias CommonsPub.Users.User
  alias CommonsPub.Workers.APPublishWorker

  alias CommonsPub.Utils.Web.CommonHelper

  def cursor(:followers), do: &[&1.follower_count, &1.id]

  def test_cursor(:followers), do: &[&1["followerCount"], &1["id"]]

  @doc "Retrieves a single collection by arbitrary filters."
  def one(filters), do: Repo.single(Queries.query(Collection, filters))

  def get(username) do
    with {:ok, c} <- one([:default, username: username]) do
      c
    end
  end

  @doc "Retrieves a list of collections by arbitrary filters."
  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Collection, filters))}

  @spec create(User.t(), Community.t(), attrs :: map) ::
          {:ok, Collection.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %{} = community_or_context, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      # attrs = Characters.prepare_username(attrs)

      # TODO: address activity to context's outbox/followers
      community_or_context = CommonHelper.maybe_preload(community_or_context, :character)

      # with {:ok, character} <- Characters.create(creator, attrs),
      #      {:ok, coll_attrs} <- create_boxes(character, attrs),
      with {:ok, coll} <- insert_collection(creator, community_or_context, attrs),
           {:ok, character} <- Characters.create(creator, attrs, coll),
           act_attrs = %{verb: "created", is_local: true},
           {:ok, activity} <- Activities.create(creator, coll, act_attrs),
           :ok <- publish(creator, community_or_context, coll, activity),
           :ok <- ap_publish("create", coll) do
        #  {:ok, _follow} <- Follows.create(creator, coll, %{is_local: true})

        CommonsPub.Search.Indexer.maybe_index_object(coll)

        {:ok, %{coll | character: character}}
      end
    end)
  end

  def create(%User{} = creator, _, attrs) when is_map(attrs) do
    create(creator, attrs)
  end

  # Create without context
  def create(%User{} = creator, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      # attrs = Characters.prepare_username(attrs)

      with {:ok, coll} <- insert_collection(creator, attrs),
           {:ok, character} <- Characters.create(creator, attrs, coll),
           act_attrs = %{verb: "created", is_local: true},
           {:ok, activity} <- Activities.create(creator, coll, act_attrs),
           :ok <- publish(creator, coll, activity),
           :ok <- ap_publish("create", coll) do
        #  {:ok, _follow} <- Follows.create(creator, coll, %{is_local: true}) do
        CommonsPub.Search.Indexer.maybe_index_object(coll)

        {:ok, %{coll | character: character}}
      end
    end)
  end

  @spec create_remote(User.t(), Community.t(), attrs :: map) ::
          {:ok, Collection.t()} | {:error, Changeset.t()}
  def create_remote(%User{} = creator, %Community{} = community, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      with {:ok, coll} <- insert_collection(creator, community, attrs),
           {:ok, character} <- Characters.create(creator, attrs, coll),
           act_attrs = %{verb: "created", is_local: true},
           {:ok, activity} <- Activities.create(creator, coll, act_attrs),
           :ok <- publish(creator, community, coll, activity) do
        CommonsPub.Search.Indexer.maybe_index_object(coll)

        {:ok, %{coll | character: character}}
      end
    end)
  end

  defp insert_collection(creator, context, attrs) do
    cs = Collection.create_changeset(creator, context, attrs)

    with {:ok, coll} <- Repo.insert(cs),
         do: {:ok, %{coll | context: context}}
  end

  defp insert_collection(creator, attrs) do
    cs = Collection.create_changeset(creator, attrs)
    with {:ok, coll} <- Repo.insert(cs), do: {:ok, coll}
  end

  @spec update(User.t(), %Collection{}, attrs :: map) ::
          {:ok, Collection.t()} | {:error, Changeset.t()}
  def update(%User{} = user, %Collection{} = collection, attrs) do
    Repo.transact_with(fn ->
      collection = Repo.preload(collection, :community)

      with {:ok, collection} <- Repo.update(Collection.update_changeset(collection, attrs)),
           {:ok, character} <- Characters.update(user, collection.character, attrs),
           collection = %{collection | character: character},
           :ok <- ap_publish("update", collection) do
        {:ok, collection}
      end
    end)
  end

  def update_by(%User{}, filters, updates) do
    Repo.update_all(Queries.query(Collection, filters), set: updates)
  end

  def soft_delete(%User{} = user, %Collection{} = collection) do
    Repo.transact_with(fn ->
      with {:ok, collection} <- Common.soft_delete(collection),
           %{collection: colls, feed: feeds} = deleted_ids([collection]),
           :ok <- chase_delete(user, colls, feeds),
           :ok <- ap_publish("delete", collection) do
        {:ok, collection}
      end
    end)
  end

  @delete_by_filters [select: :delete, deleted: false]

  def soft_delete_by(%User{} = user, filters) do
    with {:ok, _} <-
           Repo.transact_with(fn ->
             {_, ids} =
               update_by(user, @delete_by_filters ++ filters, deleted_at: DateTime.utc_now())

             %{collection: collection, feed: feed} = deleted_ids(ids)

             with :ok <- chase_delete(user, collection, feed) do
               ap_publish("delete", collection)
             end
           end),
         do: :ok
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
    CommonsPub.Config.get!(__MODULE__)
    |> Keyword.fetch!(:default_outbox_query_contexts)
  end

  defp publish(creator, %{character: %{outbox_id: context_outbox}}, collection, activity) do
    feeds = [
      context_outbox,
      CommonsPub.Feeds.outbox_id(creator),
      collection.outbox_id,
      Feeds.instance_outbox_id()
    ]

    FeedActivities.publish(activity, feeds)
  end

  defp publish(creator, %{outbox_id: community_or_context_outbox}, collection, activity) do
    feeds = [
      community_or_context_outbox,
      CommonsPub.Feeds.outbox_id(creator),
      collection.outbox_id,
      Feeds.instance_outbox_id()
    ]

    FeedActivities.publish(activity, feeds)
  end

  defp publish(creator, _, collection, activity) do
    publish(creator, collection, activity)
  end

  defp publish(creator, collection, activity) do
    feeds = [
      CommonsPub.Feeds.outbox_id(creator),
      collection.outbox_id,
      Feeds.instance_outbox_id()
    ]

    FeedActivities.publish(activity, feeds)
  end

  defp ap_publish(verb, collections) when is_list(collections) do
    APPublishWorker.batch_enqueue(verb, collections)
    :ok
  end

  defp ap_publish(verb, %{character: %{peer_id: nil}} = collection) do
    APPublishWorker.enqueue(verb, %{"context_id" => collection.id})
    :ok
  end

  defp ap_publish(_, _), do: :ok

  def ap_publish_activity("create", collection) do
    with {:ok, actor} <- ActivityPub.Actor.get_cached_by_local_id(collection.creator_id),
         {:ok, ap_collection} <- ActivityPub.Actor.get_cached_by_local_id(collection.id),
         collection_object <-
           ActivityPubWeb.ActorView.render("actor.json", %{actor: ap_collection}),
         # FIXME: optional
         {:ok, ap_context} <- ActivityPub.Actor.get_cached_by_local_id(collection.context_id),
         params <- %{
           actor: actor,
           to: [CommonsPub.ActivityPub.Utils.public_uri(), ap_context.ap_id],
           object: collection_object,
           context: ActivityPub.Utils.generate_context_id(),
           additional: %{
             "cc" => [actor.data["followers"]]
           }
         },
         {:ok, activity} <- ActivityPub.create(params) do
      Ecto.Changeset.change(collection.character, %{canonical_url: collection_object["id"]})
      |> Repo.update()

      {:ok, activity}
    else
      e -> {:error, e}
    end
  end

  def indexing_object_format(%CommonsPub.Collections.Collection{} = collection) do
    collection = CommonHelper.maybe_preload(collection, [:context, :creator])
    context = CommonHelper.maybe_preload(collection.context, :character)

    follower_count =
      case CommonsPub.Follows.FollowerCounts.one(context: collection.id) do
        {:ok, struct} -> struct.count
        {:error, _} -> nil
      end

    icon = CommonsPub.Uploads.remote_url_from_id(collection.icon_id)
    url = CommonsPub.ActivityPub.Utils.get_actor_canonical_url(collection)

    %{
      "index_type" => "Collection",
      "id" => collection.id,
      "canonical_url" => url,
      "followers" => %{
        "total_count" => follower_count
      },
      "icon" => icon,
      "name" => collection.name,
      "username" => CommonsPub.Characters.display_username(collection),
      "summary" => Map.get(collection, :summary),
      "published_at" => collection.published_at,
      "index_instance" => CommonsPub.Search.Indexer.host(url),
      "context" => CommonsPub.Search.Indexer.maybe_indexable_object(context),
      "creator" => CommonsPub.Search.Indexer.format_creator(collection)
    }
  end
end
