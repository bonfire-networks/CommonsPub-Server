# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Taxonomy.GraphQL.LocalesResolver do
  @moduledoc "GraphQL Language and Country queries"
  alias MoodleNet.{GraphQL}
  alias Taxonomy.{Locales}

  def languages(_, info) do
    Locales.nodes_page(
      &(&1.id),
      [],
      [order: :speakers]
      )
  end

  # def language(%{language_id: id}, info) do
  #   {:ok, Fake.language()}
  #   |> GraphQL.response(info)
  # end

  # def search_language(%{query: id}, info) do
  #   {:ok, Fake.long_node_list(&Fake.language/0)}
  #   |> GraphQL.response(info)
  # end

  # def countries(_, info) do
  #   {:ok, Fake.long_node_list(&Fake.country/0)}
  #   |> GraphQL.response(info)
  # end

  # def country(%{country_id: id}, info) do
  #   {:ok, Fake.country()}
  #   |> GraphQL.response(info)
  # end

  # def search_country(%{query: id}, info) do
  #   {:ok, Fake.long_node_list(&Fake.country/0)}
  #   |> GraphQL.response(info)
  # end

  # def primary_language(parent, _, info) do
  #   {:ok, Fake.language()}
  #   |> GraphQL.response(info)
  # end

end
