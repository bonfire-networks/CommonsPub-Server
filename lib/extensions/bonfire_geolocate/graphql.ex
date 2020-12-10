# SPDX-License-Identifier: AGPL-3.0-only
defmodule Bonfire.Geolocate.GraphQL do
  use Absinthe.Schema.Notation
  require Logger

  @repo CommonsPub.Repo

  alias Bonfire.GraphQL
  alias Bonfire.GraphQL.{
    # ResolvePage,
    # ResolvePages,
    ResolveField,
    ResolveFields,
    ResolveRootPage,
    FetchPage,
    FetchFields,
    # FetchPages,
    # CommonResolver,
    Fields, Page}

  # alias CommonsPub.Resources.Resource
  # alias Bonfire.Common.Enums

  alias Bonfire.Geolocate.Geolocation
  alias Bonfire.Geolocate.Geolocations
  alias Bonfire.Geolocate.Queries
  alias Organisation

  # SDL schema import

  import_sdl(path: "lib/extensions/bonfire_geolocate/geolocation.gql")

  ## resolvers


  def fields(group_fn, filters \\ [])
      when is_function(group_fn, 1) do
    {:ok, fields} = Geolocations.many(filters)
    {:ok, Fields.new(fields, group_fn)}
  end

  @doc """
  Retrieves an Page of geolocations according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])

  def page(cursor_fn, %{} = page_opts, base_filters, data_filters, count_filters) do
    base_q = Queries.query(Geolocation, base_filters)
    data_q = Queries.filter(base_q, data_filters)
    count_q = Queries.filter(base_q, count_filters)

    with {:ok, [data, counts]} <- @repo.transact_many(all: data_q, count: count_q) do
      {:ok, Page.new(data, counts, cursor_fn, page_opts)}
    end
  end

  @doc """
  Retrieves an Pages of geolocations according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def pages(
        cursor_fn,
        group_fn,
        page_opts,
        base_filters \\ [],
        data_filters \\ [],
        count_filters \\ []
      )

  def pages(cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters) do
    Bonfire.GraphQL.Pagination.pages(
      Queries,
      Geolocation,
      cursor_fn,
      group_fn,
      page_opts,
      base_filters,
      data_filters,
      count_filters
    )
  end


  def geolocation(%{id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_geolocation,
      context: id,
      info: info
    })
  end

  def all_geolocations(_page_opts, _info) do
    Geolocations.many()
  end

  def geolocations(page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_geolocations,
      page_opts: page_opts,
      info: info,
      # popularity
      cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1]
    })
  end

  ## fetchers

  def fetch_geolocation(info, id) do
    with {:ok, geo} <-
           Geolocations.one([:default, user: GraphQL.current_user(info), id: id]) do
      {:ok, Geolocations.populate_coordinates(geo)}
    end
  end

  def fetch_geolocations(page_opts, info) do
    # FIXME once we re-integrate Character:
    # page_result =
    #   FetchPage.run(%FetchPage{
    #     queries: Queries,
    #     query: Geolocation,
    #     cursor_fn: Geolocations.cursor(:followers),
    #     page_opts: page_opts,
    #     base_filters: [user: GraphQL.current_user(info)],
    #     data_filters: [page: [desc: [followers: page_opts]]]
    #   })

    page_result =
      FetchPage.run(%FetchPage{
        queries: Queries,
        query: Geolocation,
        page_opts: page_opts,
        base_filters: [user: GraphQL.current_user(info)]
      })

    with {:ok, %{edges: edges} = page} <- page_result do
      edges = Enum.map(edges, &Geolocations.populate_coordinates/1)
      {:ok, %{page | edges: edges}}
    end
  end

  def last_activity_edge(_, _, _info) do
    {:ok, DateTime.utc_now()}
  end

  def geolocation_edge(%{spatial_thing_id: id}, _, info) do
    geolocation_edge(%{geolocation_id: id}, nil, info)
  end

  def geolocation_edge(%{geolocation_id: id}, _, info) do
    ResolveFields.run(%ResolveFields{
      module: __MODULE__,
      fetcher: :fetch_geolocation_edge,
      context: id,
      info: info
    })
  end

  def geolocation_edge(_, _, _) do
    {:ok, nil}
  end

  def fetch_geolocation_edge(_, ids) do
    FetchFields.run(%FetchFields{
      queries: Bonfire.Geolocate.Queries,
      query: Bonfire.Geolocate.Geolocation,
      group_fn: & &1.id,
      filters: [:default, id: ids]
    })
  end

  # defp default_outbox_query_contexts() do
  #   CommonsPub.Config.get!(Geolocations)
  #   |> Keyword.fetch!(:default_outbox_query_contexts)
  # end

  ## finally the mutations...

  def create_geolocation(%{spatial_thing: attrs, in_scope_of: context_id}, info) do
    @repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, pointer} <- Bonfire.Common.Pointers.one(id: context_id),
           context = Bonfire.Common.Pointers.follow!(pointer),
           attrs = Map.merge(attrs, %{is_public: true}),
           {:ok, g} <- Geolocations.create(user, context, attrs) do
        {:ok, %{spatial_thing: g}}
      end
    end)
  end

  def create_geolocation(%{spatial_thing: attrs}, info) do
    @repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           attrs = Map.merge(attrs, %{is_public: true}),
           {:ok, g} <- Geolocations.create(user, attrs) do
        {:ok, %{spatial_thing: g}}
      end
    end)
  end

  def update_geolocation(%{spatial_thing: %{id: id} = changes}, info) do
    @repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, geolocation} <- geolocation(%{id: id}, info),
           :ok <- ensure_update_allowed(user, geolocation),
           {:ok, geo} <- Geolocations.update(user, geolocation, changes) do
        {:ok, %{spatial_thing: geo}}
      end
    end)
  end

  def ensure_update_allowed(user, geo) do
    if user.local_user.is_instance_admin or geo.creator_id == user.id do
      :ok
    else
      GraphQL.not_permitted("update")
    end
  end

  def delete_geolocation(%{id: id}, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
         {:ok, geo} <- geolocation(%{id: id}, info),
         :ok <- ensure_delete_allowed(user, geo),
         {:ok, _geo} <- Geolocations.soft_delete(user, geo) do
      {:ok, true}
    end
  end

  def ensure_delete_allowed(user, geo) do
    if user.local_user.is_instance_admin or geo.creator_id == user.id do
      :ok
    else
      GraphQL.not_permitted("delete")
    end
  end
end
