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
  alias MoodleNet.GraphQL.{
    Flow,
    FetchFields,
    FetchPage,
    FetchPages,
    ResolveField,
    ResolvePage,
    ResolvePages,
    ResolveRootPage,
  }
  alias MoodleNet.Collections.{Collection, Queries}
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Common.Enums
  alias MoodleNetWeb.GraphQL.{CommunitiesResolver, UploadResolver}
  import Ecto.Query

  ## resolvers

  def collection(%{collection_id: id}, info) do
    ResolveField.run(
      %ResolveField{
        module: __MODULE__,
        fetcher: :fetch_collection,
        context: id,
        info: info,
      }
    )
  end

  def collections(page_opts, info) do
    ResolveRootPage.run(
      %ResolveRootPage{
        module: __MODULE__,
        fetcher: :fetch_collections,
        page_opts: page_opts,
        info: info,
        cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1], # popularity
      }
    )
  end

  ## fetchers

  def fetch_collection(info, id) do
    Collections.one(
      user: GraphQL.current_user(info),
      id: id,
      preload: :actor
    )
  end

  def fetch_collections(page_opts, info) do
    FetchPage.run(
      %FetchPage{
        queries: Collections.Queries,
        query: Collection,
        cursor_fn: Collections.cursor(:followers),
        page_opts: page_opts,
        base_filters: [user: GraphQL.current_user(info)],
        data_filters: [page: [desc: [followers: page_opts]]],
      }
    )
  end

  def resource_count_edge(%Collection{id: id}, _, info) do
    Flow.fields __MODULE__, :fetch_resource_count_edge, id, info, default: 0
  end

  def fetch_resource_count_edge(_, ids) do
    FetchFields.run(
      %FetchFields{
        queries: Resources.Queries,
        query: Resource,
        group_fn: &elem(&1, 0),
        map_fn: &elem(&1, 1),
        filters: [collection_id: ids, group_count: :collection_id],
      }
    )
  end

  def resources_edge(%Collection{id: id}, %{}=page_opts, info) do
    ResolvePages.run(
      %ResolvePages{
        module: __MODULE__,
        fetcher: :fetch_resources_edge,
        context: id,
        page_opts: page_opts,
        info: info,
      }
    )
  end

  # def fetch_resources_edge({page_opts, info}, ids) do
  #   limit = page_opts.limit
  #   user = GraphQL.current_user(info)
  #   base_query = from c in Collection, where: c.id in ^ids
  #   data_query = from c in subquery(base_query), as: :collection,
  #     inner_lateral_join: r in ^subquery(
  #       from r in Resource, as: :resource,
  #       where: r.collection_id == parent_as(:collection).id,
  #       order_by: [desc: r.id],
  #       limit: ^limit
  #     ),
  #     select: %Resource{
  #       id: r.id, creator_id: r.creator_id, collection_id: r.collection_id,
  #       content_id: r.content_id, icon_id: r.icon_id, name: r.name,
  #       summary: r.summary, license: r.license, author: r.author,
  #       published_at: r.published_at, disabled_at: r.disabled_at,
  #       deleted_at: r.deleted_at, updated_at: r.updated_at,
  #     }

  #   count_query = Resources.Queries.query Resource,
  #     collection_id: ids,
  #     group_count: :collection_id
    
  #   FetchPages.run(
  #     %FetchPages{
  #       cursor_fn: &[&1.id],
  #       group_fn: &(&1.collection_id),
  #       page_opts: page_opts,
  #       base_filters: [:deleted, user: user, collection_id: ids],
  #       data_query: data_query,
  #       count_query: count_query,
  #     }
  #   )
  # end

  def fetch_resources_edge(page_opts, info, id) do
    user = GraphQL.current_user(info)
    FetchPage.run(
      %FetchPage{
        queries: Resources.Queries,
        query: Resource,
        cursor_fn: &[&1.id],
        page_opts: page_opts,
        base_filters: [:deleted, user: user, collection_id: id],
        data_filters: [page: [desc: [created: page_opts]]],
      }
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

  def outbox_edge(%Collection{outbox_id: id}, page_opts, info) do
    ResolvePages.run(
      %ResolvePages{
        module: __MODULE__,
        fetcher: :fetch_outbox_edge,
        context: id,
        page_opts: page_opts,
        info: info,
      }
    )
  end

  def fetch_outbox_edge({page_opts, info}, id) do
    user = info.context.current_user
    {:ok, box} = Activities.page(
      &(&1.id),
      &(&1.id),
      page_opts,
      feed: id,
      table: default_outbox_query_contexts()
    )
    box
  end

  def fetch_outbox_edge(page_opts, info, id) do
    user = info.context.current_user
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

  def create_collection(%{collection: attrs, community_id: id} = params, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, uploads} <- UploadResolver.upload(user, params, info),
           {:ok, community} <- CommunitiesResolver.community(%{community_id: id}, info) do
        attrs = attrs
        |> Map.put(:is_public, true)
        |> Map.merge(uploads)

        Collections.create(user, community, attrs)
      end
    end)
  end

  def update_collection(%{collection: changes, collection_id: id} = params, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, collection} <- collection(%{collection_id: id}, info) do
        collection = Repo.preload(collection, :community)
        permitted? = user.local_user.is_instance_admin or
          collection.community.creator_id == user.id

        if permitted? do
          with {:ok, uploads} <- UploadResolver.upload(user, params, info) do
            Collections.update(collection, Map.merge(changes, uploads))
          end
        else
          GraphQL.not_permitted("update")
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
