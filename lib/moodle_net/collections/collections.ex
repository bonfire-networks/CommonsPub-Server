# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Collections do
  alias MoodleNet.{Activities, Actors, Common, Feeds, Follows, Repo}
  alias MoodleNet.Batching.{Edges, EdgesPage, EdgesPages}
  alias MoodleNet.Collections.{Collection,  Queries}
  alias MoodleNet.Communities.Community
  alias MoodleNet.Feeds.FeedActivities
  alias MoodleNet.Users.User

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

  def edges(group_fn, filters \\ [])
  when is_function(group_fn, 1) do
    {:ok, edges} = many(filters)
    {:ok, Edges.new(edges, group_fn)}
  end

  @doc """
  Retrieves an EdgesPage of collections according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def edges_page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def edges_page(cursor_fn, %{}=page_opts, base_filters, data_filters, count_filters)
  when is_function(cursor_fn, 1) do
    {data_q, count_q} = Queries.queries(Collection, base_filters, data_filters, count_filters)
    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, EdgesPage.new(data, counts, cursor_fn, page_opts)}
    end
  end

  @doc """
  Retrieves an EdgesPages of collections according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def edges_pages(cursor_fn, group_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def edges_pages(cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters)
  when is_function(cursor_fn, 1) and is_function(group_fn, 1) do
    {data_q, count_q} = Queries.queries(Collection, base_filters, data_filters, count_filters)
    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, all: count_q) do
      {:ok, EdgesPages.new(data, counts, cursor_fn, group_fn, page_opts)}
    end
  end

  ## mutations

  @spec create(User.t(), Community.t(), attrs :: map) :: {:ok, Collection.t()} | {:error, Changeset.t()}
  def create(%User{} = creator, %Community{} = community, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      with {:ok, actor} <- Actors.create(attrs),
           {:ok, coll_attrs} <- create_boxes(actor, attrs),
           {:ok, coll} <- insert_collection(creator, community, actor, coll_attrs),
           act_attrs = %{verb: "created", is_local: true},
           {:ok, activity} <- Activities.create(creator, coll, act_attrs),
           :ok <- publish(creator, community, coll, activity, :created),
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
    with :ok <- FeedActivities.publish(activity, feeds) do
      ap_publish(collection.id, creator.id, collection.actor.peer_id)
    end
  end
  defp publish(collection, :updated) do
    ap_publish(collection.id, collection.creator_id, collection.actor.peer_id) # TODO: wrong if edited by admin
  end
  defp publish(collection, :deleted) do
    ap_publish(collection.id, collection.creator_id, collection.actor.peer_id) # TODO: wrong if edited by admin
  end

  defp ap_publish(context_id, user_id, nil) do
    MoodleNet.FeedPublisher.publish(%{
      "context_id" => context_id,
      "user_id" => user_id,
    })
  end
  defp ap_publish(_, _, _), do: :ok

  # TODO: take the user who is performing the update
  @spec update(%Collection{}, attrs :: map) :: {:ok, Collection.t()} | {:error, Changeset.t()}
  def update(%Collection{} = collection, attrs) do
    Repo.transact_with(fn ->
      collection = Repo.preload(collection, :community)
      with {:ok, collection} <- Repo.update(Collection.update_changeset(collection, attrs)),
           {:ok, actor} <- Actors.update(collection.actor, attrs),
           :ok <- publish(collection, :updated) do
        {:ok, %{ collection | actor: actor }}
      end
    end)
  end

  def soft_delete(%Collection{} = collection) do
    Repo.transact_with(fn ->
      with {:ok, collection} <- Common.soft_delete(collection),
           :ok <- publish(collection, :deleted) do
        {:ok, collection}
      end
    end)
  end

end
