# SPDX-License-Identifier: AGPL-3.0-only
defmodule Measurement.Unit.GraphQL do
  use Absinthe.Schema.Notation
  require Logger

  alias MoodleNet.{
    Activities,
    GraphQL,
    Repo,
  }
  alias MoodleNet.GraphQL.{
    CommonResolver,
    ResolveField,
    ResolveFields,
    ResolvePage,
    ResolvePages,
    ResolveRootPage,
    FetchPage,
    FetchPages,
  }
  # alias MoodleNet.Resources.Resource
  alias MoodleNet.Common.Enums
  alias MoodleNet.Meta.Pointers

  alias ValueFlows.Simulate
  alias Measurement.Unit
  alias Measurement.Unit.Units
  alias Measurement.Unit.Queries

  import_sdl path: "lib/measurement/measurement.gql"

  ## resolvers

  def unit(%{id: id}, info) do
    ResolveField.run(
      %ResolveField{
        module: __MODULE__,
        fetcher: :fetch_unit,
        context: id,
        info: info,
      }
    )
  end

  def units(page_opts, info) do
    ResolveRootPage.run(
      %ResolveRootPage{
        module: __MODULE__,
        fetcher: :fetch_units,
        page_opts: page_opts,
        info: info,
        cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1], # popularity
      }
    )
  end

  ## fetchers

  def fetch_unit(info, id) do
    Units.one(
      user: GraphQL.current_user(info),
      id: id
    )
  end

  # FIXME
  def fetch_units(page_opts, info) do
    FetchPage.run(
      %FetchPage{
        queries: Queries,
        query: Unit,
        cursor_fn: &(&1.id),
        page_opts: page_opts,
        base_filters: [user: GraphQL.current_user(info)],
      }
    )
  end

  def context_edge(params, data, info), do: CommonResolver.context_edge(params, data, info)

  # def fetch_community_edge(_, ids) do
  #   {:ok, fields} = Communities.fields(&(&1.id), [:default, id: ids])
  #   fields
  # end

  def create_unit(%{unit: attrs, in_scope_of_context_id: context_id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, pointer} <- Pointers.one(id: context_id),
           context = Pointers.follow!(pointer),
           attrs = Map.merge(attrs, %{is_public: true}),
           {:ok, unit} <- Units.create(user, context, attrs) do
        {:ok, %{unit: unit}}
      end
    end)
  end

  def create_unit(%{unit: attrs}, info) do # without community scope
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           attrs = Map.merge(attrs, %{is_public: true}),
           {:ok, unit} <- Units.create(user, attrs) do
        {:ok, %{unit: unit}}
      end
    end)
  end

  def update_unit(%{unit: changes, unit_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, unit} <- unit(%{id: id}, info) do
        unit = Repo.preload(unit, :context)
        cond do
          user.local_user.is_instance_admin ->
            {:ok, u} = Units.update(unit, changes)
            {:ok, %{unit: u}}

          unit.creator_id == user.id ->
            {:ok, u} = Units.update(unit, changes)
            {:ok, %{unit: u}}
          true -> GraphQL.not_permitted("update")
        end
      end
    end)
  end


  # TEMP
  def all_units(_, _, _) do
    {:ok, Simulate.long_list(&Simulate.unit/0)}
  end

  def a_unit(%{id: id}, info) do
    {:ok, Simulate.unit()}
  end


end

