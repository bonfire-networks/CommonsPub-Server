# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Locales.GraphQL.Resolver do
  @moduledoc "GraphQL Language and Country queries"
  # alias CommonsPub.{GraphQL}
  alias CommonsPub.GraphQL.{
    # CommonResolver,
    # Flow,
    # FetchFields,
    FetchPage,
    # FetchPages,
    ResolveField,
    # ResolveFields,
    # ResolvePage,
    # ResolvePages,
    ResolveRootPage
  }

  alias CommonsPub.Locales.Language
  alias CommonsPub.Locales.Languages
  alias CommonsPub.Locales.Country
  alias CommonsPub.Locales.Countries

  def language(%{language_id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_language,
      context: id,
      info: info
    })
  end

  def languages(page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_languages,
      page_opts: page_opts,
      info: info,
      # popularity
      cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1]
    })
  end

  ## fetchers

  def fetch_language(_info, id) do
    Languages.one(
      # user: GraphQL.current_user(info),
      id: id
    )
  end

  def fetch_languages(page_opts, _info) do
    FetchPage.run(%FetchPage{
      queries: CommonsPub.Locales.Languages.Queries,
      query: Language,
      # cursor_fn: Locales.cursor,
      page_opts: page_opts,
      # base_filters: [user: GraphQL.current_user(info)],
      data_filters: [{:order, :speakers}]
    })
  end

  def country(%{country_id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_country,
      context: id,
      info: info
    })
  end

  def countries(page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_countries,
      page_opts: page_opts,
      info: info,
      # popularity
      cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1]
    })
  end

  ## fetchers

  def fetch_country(_info, id) do
    Countries.one(
      # user: GraphQL.current_user(info),
      id: id
    )
  end

  def fetch_countries(page_opts, _info) do
    FetchPage.run(%FetchPage{
      queries: CommonsPub.Locales.Countries.Queries,
      query: Country,
      # cursor_fn: Locales.cursor,
      page_opts: page_opts
      # base_filters: [user: GraphQL.current_user(info)],
      # data_filters: [page: [desc: [followers: page_opts]]],
    })
  end

  # def language(%{language_id: id}, info) do
  #   {:ok, Simulation.language()}
  #   |> GraphQL.response(info)
  # end

  # def countries(_, info) do
  #   {:ok, Simulation.long_node_list(&Simulation.country/0)}
  #   |> GraphQL.response(info)
  # end

  # def country(%{country_id: id}, info) do
  #   {:ok, Simulation.country()}
  #   |> GraphQL.response(info)
  # end

  # def primary_language(parent, _, info) do
  #   {:ok, Simulation.language()}
  #   |> GraphQL.response(info)
  # end
end
