# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Measurement.Measure.GraphQL do
  alias MoodleNet.{
    Activities,
    # Communities,
    GraphQL,
    Repo,
  }
  alias MoodleNet.GraphQL.{
    FetchFields,
    FetchPage,
    FetchPages,
    ResolveField,
    ResolvePage,
    ResolvePages,
    ResolveRootPage,
  }
  # alias MoodleNet.Resources.Resource
  alias MoodleNet.Common.Enums
  # alias MoodleNetWeb.GraphQL.CommunitiesResolver

  alias ValueFlows.Simulate
  alias ValueFlows.Measurement.Measure
  alias ValueFlows.Measurement.Measure.Units
  alias ValueFlows.Measurement.Measure.Queries

  # SDL schema import

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver}
  require Logger

  import_sdl path: "lib/value_flows/graphql/schemas/measurement.gql"

  ## resolvers

  def measure(%{id: id}, info) do
    ResolveField.run(
      %ResolveField{
        module: __MODULE__,
        fetcher: :fetch_measure,
        context: id,
        info: info,
      }
    )
  end

  def measures(page_opts, info) do
    ResolveRootPage.run(
      %ResolveRootPage{
        module: __MODULE__,
        fetcher: :fetch_measures,
        page_opts: page_opts,
        info: info,
        cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1], # popularity
      }
    )
  end

  ## fetchers

  def fetch_measure(info, id) do
    Units.one(
      user: GraphQL.current_user(info),
      id: id
    )
  end

  # FIXME
  def fetch_measures(page_opts, info) do
    FetchPage.run(
      %FetchPage{
        queries: Queries,
        query: Measure,
        cursor_fn: &(&1.id),
        page_opts: page_opts,
        base_filters: [user: GraphQL.current_user(info)],
      }
    )
  end



  ## finally the mutations...

  def create_measure(%{measure: attrs}, info) do
    IO.inspect(attrs)
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
        attrs = Map.merge(attrs, %{is_public: true})
        {:ok, u} = Units.create(user, attrs)
        IO.inspect(u)
        {:ok, %{measure: u}}
      end
    end)
  end

  def update_measure(%{measure: changes, measure_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, measure} <- measure(%{id: id}, info) do
        # IO.inspect(measure)
        cond do
          user.local_user.is_instance_admin ->
            {:ok, u} = Units.update(measure, changes)
            {:ok, %{measure: u}}

          measure.creator_id == user.id ->
            {:ok, u} = Units.update(measure, changes)
            {:ok, %{measure: u}}
          true -> GraphQL.not_permitted("update")
        end
      end
    end)
  end


  # TEMP
  def all_measures(_, _, _) do
    {:ok, Simulate.long_list(&Simulate.measure/0)}
  end

  def a_measure(%{id: id}, info) do
    {:ok, Simulate.measure()}
  end


end

