# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CollectionsResolver do
  alias MoodleNet.{
    Activities,
    Collections,
    Communities,
    GraphQL,
    Repo,
    Resources,
  }
  alias MoodleNet.GraphQL.{Flow, PageFlow}
  alias MoodleNet.Collections.{Collection, Queries}
  alias MoodleNet.Common.Enums
  alias MoodleNetWeb.GraphQL.CommunitiesResolver

  ## resolvers

  def collection(%{collection_id: id}, info) do
    Flow.field(__MODULE__, :fetch_collection, id, info)
  end

  def collections(page_opts, info) do
    opts = %{default_limit: 10, cursor_fn: &GraphQL.cast_int_ulid_id/1}
    Flow.root_page(__MODULE__, :fetch_collections, page_opts, info, opts)
  end

  ## fetchers

  def fetch_collection(user, id) do
    Collections.one(
      user: user,
      id: id,
      preload: :actor
    )
  end

  def fetch_collections(page_opts, user) do
   PageFlow.run(
      %PageFlow{
        queries_module: Queries,
        query: Collection,
        cursor_fn: Collections.cursor(:followers),
        page_opts: page_opts,
        base_filters: [user: user],
        data_filters: [page: [followers_desc: page_opts]],
      }
    )
  end

  def resource_count_edge(%Collection{id: id}, _, info) do
    Flow.fields __MODULE__, :fetch_resource_count_edge, id, info,
      default: 0,
      getter: &Flow.get_tuple_item(&1, id, 1, 0)
  end

  def fetch_resource_count_edge(_, ids) do
    {:ok, edges} = Resources.many(collection_id: ids, group_count: :collection_id)
    Enums.group(edges, fn {id, _} -> id end)
  end

  def resources_edge(%Collection{id: id}, %{}=page_opts, info) do
    opts = %{default_limit: 10}
    Flow.pages(__MODULE__, :fetch_resources_edge, page_opts, id, info, opts)
  end

  def fetch_resources_edge({page_opts, user}, ids) do
    {:ok, edges} = Resources.pages(
      &(&1.id),
      &(&1.collection_id),
      page_opts,
      [user: user, collection_id: ids],
      [order: :timeline_desc],
      [group_count: :collection_id]
    )
    IO.inspect(edges: edges)
    edges
  end

  def fetch_resources_edge(page_opts, user, id) do
    Resources.page(
      &(&1.id),
      page_opts,
      [user: user, collection_id: id],
      [order: :timeline_desc]
    )
  end

  def community_edge(%Collection{community_id: id}, _, info) do
    Flow.fields __MODULE__, :fetch_community_edge, id, info
  end

  def fetch_community_edge(_, ids) do
    {:ok, fields} = Communities.fields(&(&1.id), [:default, id: ids])
    fields
  end

  def last_activity_edge(_, _, _info) do
    {:ok, DateTime.utc_now()}
  end

  def outbox_edge(%Collection{outbox_id: id}, page_opts, %{context: %{current_user: user}}=info) do
    opts = %{default_limit: 10}
    Flow.pages(__MODULE__, :fetch_outbox_edge, page_opts, user, id, info, opts)
  end

  def fetch_outbox_edge({page_opts, user}, id) do
    {:ok, box} = Activities.page(
      &(&1.id),
      &(&1.id),
      page_opts,
      feed: id,
      table: default_outbox_query_contexts()
    )
    box
  end

  def fetch_outbox_edge(page_opts, user, id) do
    Activities.page(
      &(&1.id),
      page_opts,
      feed: id,
      table: default_outbox_query_contexts()
    )
  end

  defp default_outbox_query_contexts() do
    Application.fetch_env!(:moodle_net, Collections)
    |> Keyword.fetch!(:default_outbox_query_contexts)
  end

  ## finally the mutations...

  def create_collection(%{collection: attrs, community_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, community} <- CommunitiesResolver.community(%{community_id: id}, info) do
        attrs = Map.merge(attrs, %{is_public: true})
        Collections.create(user, community, attrs)
      end
    end)
  end

  def update_collection(%{collection: changes, collection_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, collection} <- collection(%{collection_id: id}, info) do
        collection = Repo.preload(collection, :community)
        cond do
          user.local_user.is_instance_admin ->
	    Collections.update(collection, changes)

          collection.creator_id == user.id ->
	    Collections.update(collection, changes)

          collection.community.creator_id == user.id ->
	    Collections.update(collection, changes)

          true -> GraphQL.not_permitted("update")
        end
      end
    end)
  end

  # def delete(%{collection_id: id}, info) do
  #   # Repo.transact_with(fn ->
  #   #   with {:ok, user} <- GraphQL.current_user(info),
  #   #        {:ok, actor} <- Users.fetch_actor(user),
  #   #        {:ok, collection} <- Collections.fetch(id) do
  #   #     collection = Repo.preload(collection, :community)
  #   # 	permitted =
  #   # 	  user.is_instance_admin or
  #   #       collection.creator_id == actor.id or
  #   #       collection.community.creator_id == actor.id
  #   # 	if permitted do
  #   # 	  with {:ok, _} <- Collections.soft_delete(collection), do: {:ok, true}
  #   # 	else
  #   # 	  GraphQL.not_permitted()
  #   #     end
  #   #   end
  #   # end)
  #   # |> GraphQL.response(info)
  #   {:ok, true}
  #   |> GraphQL.response(info)
  # end

end
