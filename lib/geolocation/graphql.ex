# SPDX-License-Identifier: AGPL-3.0-only
defmodule Geolocation.GraphQL do

  use Absinthe.Schema.Notation
  require Logger

  alias MoodleNet.{
    Activities,
    GraphQL,
    Repo,
    Meta.Pointers
  }
  alias MoodleNet.GraphQL.{
    ResolvePage,
    ResolvePages,
    ResolveField,
    ResolveFields,
    ResolveRootPage,
    FetchPage,
    FetchPages,
    CommonResolver
  }
  # alias MoodleNet.Resources.Resource
  alias MoodleNet.Common.Enums

  alias Geolocation
  alias Geolocation.Geolocations
  alias Geolocation.Queries

  # SDL schema import


  import_sdl path: "lib/geolocation/geolocation.gql"

  ## resolvers

  def geolocation(%{id: id}, info) do
    ResolveField.run(
      %ResolveField{
        module: __MODULE__,
        fetcher: :fetch_geolocation,
        context: id,
        info: info,
      }
    )
  end

  def geolocations(page_opts, info) do
    ResolveRootPage.run(
      %ResolveRootPage{
        module: __MODULE__,
        fetcher: :fetch_geolocations,
        page_opts: page_opts,
        info: info,
        cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1], # popularity
      }
    )
  end

  ## fetchers

  def fetch_geolocation(info, id) do
    Geolocations.one(
      user: GraphQL.current_user(info),
      id: id,
      preload: :actor
    )
  end

  def fetch_geolocations(page_opts, info) do
    FetchPage.run(
      %FetchPage{
        queries: Queries,
        query: Geolocation,
        cursor_fn: Geolocations.cursor(:followers),
        page_opts: page_opts,
        base_filters: [user: GraphQL.current_user(info)],
        data_filters: [page: [desc: [followers: page_opts]]],
      }
    )
  end

  def context_edge(params, data, info), do: CommonResolver.context_edge(params, data, info)


  def last_activity_edge(_, _, _info) do
    {:ok, DateTime.utc_now()}
  end

  def outbox_edge(%Geolocation{outbox_id: id}, page_opts, info) do
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
    Application.fetch_env!(:moodle_net, Geolocations)
    |> Keyword.fetch!(:default_outbox_query_contexts)
  end

  ## finally the mutations...

  def create_geolocation(%{spatial_thing: attrs, in_scope_of: context_id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
              {:ok, pointer} <- Pointers.one(id: context_id),
              context = Pointers.follow!(pointer),
              attrs = Map.merge(attrs, %{is_public: true}),
              {:ok, g} <- Geolocations.create(user, context, attrs) do
          {:ok, %{geolocation: g}}
      end
    end)
  end

  def create_geolocation(%{spatial_thing: attrs}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
        attrs = Map.merge(attrs, %{is_public: true})
        Geolocations.create(user, attrs)
      end
    end)
  end

  def update_geolocation(%{spatial_thing: changes, geolocation_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, geolocation} <- geolocation(%{geolocation_id: id}, info) do
        geolocation = Repo.preload(geolocation, :context)
        cond do
          user.local_user.is_instance_admin ->
        Geolocations.update(geolocation, changes)

          geolocation.creator_id == user.id ->
        Geolocations.update(geolocation, changes)

        #   geolocation.community.creator_id == user.id ->
        # Geolocations.update(geolocation, changes)

          true -> GraphQL.not_permitted("update")
        end
      end
    end)
  end


end
