# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ResourcesResolver do
  alias MoodleNet.{Collections, GraphQL, Repo, Resources}
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Collections.Collection
  alias MoodleNet.GraphQL.{FetchFields, ResolveFields, ResolvePages, FetchPage}
  alias MoodleNet.Resources.Resource
  alias MoodleNetWeb.GraphQL.UploadResolver

  def resource(%{resource_id: id}, info) do
    Resources.one(id: id, user: GraphQL.current_user(info))
  end

  def is_local_edge(%{collection: %Collection{actor: %Actor{peer_id: peer_id}}}, _, _) do
    {:ok, is_nil(peer_id)}
  end

  def is_local_edge(%{collection_id: id}, _, info) do
    ResolveFields.run(%ResolveFields{
      module: __MODULE__,
      fetcher: :fetch_collection_edge,
      context: id,
      info: info,
      getter_fn: fn _context, _default ->
        fn edges ->
          ret =
            edges
            |> Map.get(id, %{})
            |> Map.get(:actor, %{})
            |> Map.get(:peer_id)
            |> is_nil()

          {:ok, ret}
        end
      end
    })
  end

  def collection_edge(%Resource{collection: %Collection{} = c}, _, _info), do: {:ok, c}

  def collection_edge(%Resource{collection_id: id}, _, info) do
    ResolveFields.run(%ResolveFields{
      module: __MODULE__,
      fetcher: :fetch_collection_edge,
      context: id,
      info: info
    })
  end

  def fetch_collection_edge(_, ids) do
    FetchFields.run(%FetchFields{
      queries: Collections.Queries,
      query: Collection,
      group_fn: & &1.id,
      filters: [:default, id: ids]
    })
  end

  def resource_count_edge(%Collection{id: id}, _, info) do
    ResolveFields.run(%ResolveFields{
      module: __MODULE__,
      fetcher: :fetch_resource_count_edge,
      context: id,
      info: info,
      default: 0
    })
  end

  def fetch_resource_count_edge(_, ids) do
    FetchFields.run(%FetchFields{
      queries: Resources.Queries,
      query: Resource,
      group_fn: &elem(&1, 0),
      map_fn: &elem(&1, 1),
      filters: [collection: ids, group_count: :collection_id]
    })
  end

  def resources_edge(%{id: id}, %{} = page_opts, info) do
    ResolvePages.run(%ResolvePages{
      module: __MODULE__,
      fetcher: :fetch_resources_edge,
      context: id,
      page_opts: page_opts,
      info: info
    })
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

    FetchPage.run(%FetchPage{
      queries: Resources.Queries,
      query: Resource,
      cursor_fn: &[&1.id],
      page_opts: page_opts,
      base_filters: [deleted: false, user: user, collection: id],
      data_filters: [page: [desc: [created: page_opts]]]
    })
  end

  @doc """
  Deprecated - create resource in collection
  """
  def create_resource(%{resource: res_attrs, collection_id: collection_id} = input_attrs, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      Repo.transact_with(fn ->
        with {:ok, uploads} <- UploadResolver.upload(user, input_attrs, info),
             {:ok, collection} <- Collections.one([:default, user: user, id: collection_id]),
             res_attrs = Map.merge(res_attrs, uploads),
             {:ok, resource} <- Resources.create(user, collection, res_attrs) do
          {:ok, %{resource | collection: collection}}
        end
      end)
    end
  end

  def fetch_resource_count_edge(_, ids) do
    FetchFields.run(%FetchFields{
      queries: Resources.Queries,
      query: Resource,
      group_fn: &elem(&1, 0),
      map_fn: &elem(&1, 1),
      filters: [collection: ids, group_count: :collection_id]
    })
  end

  def resources_edge(%{id: id}, %{} = page_opts, info) do
    ResolvePages.run(%ResolvePages{
      module: __MODULE__,
      fetcher: :fetch_resources_edge,
      context: id,
      page_opts: page_opts,
      info: info
    })
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

    FetchPage.run(%FetchPage{
      queries: Resources.Queries,
      query: Resource,
      cursor_fn: &[&1.id],
      page_opts: page_opts,
      base_filters: [deleted: false, user: user, collection: id],
      data_filters: [page: [desc: [created: page_opts]]]
    })
  end

  def create_resource(%{context_id: context_id} = input_attrs, info)
      when is_nil(context_id) or context_id == "" do
    create_resource(Map.drop(input_attrs, [:context_id]), info)
  end

  @doc """
  Create resource with any context
  """
  def create_resource(%{resource: res_attrs, context_id: context_id} = input_attrs, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      Repo.transact_with(fn ->
        with {:ok, pointer} = MoodleNet.Meta.Pointers.one(id: context_id),
             :ok <- validate_context(pointer),
             context = MoodleNet.Meta.Pointers.follow!(pointer),
             {:ok, uploads} <- UploadResolver.upload(user, input_attrs, info),
             res_attrs = Map.merge(res_attrs, uploads),
             {:ok, resource} <- Resources.create(user, context, res_attrs) do
          {:ok, %{resource | context: context}}
        end
      end)
    end
  end

  @doc """
  Deprecated - create resource in collection
  """
  def create_resource(%{resource: res_attrs, collection_id: collection_id} = input_attrs, info) do
    create_resource(Map.merge(input_attrs, %{context_id: collection_id}), info)
  end

  @doc """
  Create resource without context
  """
  def create_resource(%{resource: res_attrs} = input_attrs, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      Repo.transact_with(fn ->
        with {:ok, uploads} <- UploadResolver.upload(user, input_attrs, info),
             res_attrs = Map.merge(res_attrs, uploads),
             {:ok, resource} <- Resources.create(user, res_attrs) do
          {:ok, resource}
        end
      end)
    end
  end

  def update_resource(%{resource: changes, resource_id: resource_id} = input_attrs, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      Repo.transact_with(fn ->
        with {:ok, resource} <- resource(%{resource_id: resource_id}, info) do
          resource = Repo.preload(resource, collection: :community)

          permitted? =
            user.local_user.is_instance_admin or
              resource.collection.creator_id == user.id or
              resource.collection.community.creator_id == user.id

          if permitted? do
            with {:ok, uploads} <- UploadResolver.upload(user, input_attrs, info) do
              Resources.update(user, resource, Map.merge(changes, uploads))
            end
          else
            GraphQL.not_permitted()
          end
        end
      end)
    end
  end

  def copy_resource(%{resource_id: resource_id, collection_id: collection_id}, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
      Repo.transact_with(fn ->
        with {:ok, collection} <- Collections.one([:default, id: collection_id, user: user]),
             {:ok, resource} <- resource(%{resource_id: resource_id}, info),
             res_attrs = Map.take(resource, ~w(content_id name summary icon url license)a) do
          Resources.create(user, collection, res_attrs)
        end
      end)
    end
  end

  def last_activity_edge(_, _, _info), do: {:ok, DateTime.utc_now()}

  defp validate_context(pointer) do
    if MoodleNet.Meta.Pointers.table!(pointer).schema in valid_contexts() do
      :ok
    else
      GraphQL.not_permitted()
    end
  end

  defp valid_contexts() do
    Keyword.fetch!(Application.get_env(:moodle_net, Resources), :valid_contexts)
  end
end
