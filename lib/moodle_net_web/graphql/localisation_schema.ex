# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.LocalisationSchema do
  @moduledoc "GraphQL languages and countries"

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.LocalisationResolver

  object :localisation_queries do

    @desc "Get list of languages we know about"
    field :languages, :languages_nodes do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &LocalisationResolver.languages/2
    end

    @desc "Get list of languages we know about"
    field :countries, :countries_nodes do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &LocalisationResolver.countries/2
    end

  end

  object :language do
    @desc "2-letter ISO code"
    field :id, :string
    field :english_name, :string
    field :local_name, :string
  end

  object :languages_nodes do
    field :page_info, non_null(:page_info)
    field :nodes, list_of(:language)
    field :total_count, non_null(:integer)
  end

  object :languages_edges do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:languages_edge)
    field :total_count, non_null(:integer)
  end

  object :languages_edge do
    field :cursor, non_null(:string)
    field :node, :language
  end

  object :country do
    @desc "2-letter ISO code"
    field :id, :string
    field :english_name, :string
    field :local_name, :string
  end

  object :countries_nodes do
    field :page_info, non_null(:page_info)
    field :nodes, list_of(:country)
    field :total_count, non_null(:integer)
  end

  object :countries_edges do
    field :page_info, non_null(:page_info)
    field :edges, list_of(:countries_edge)
    field :total_count, non_null(:integer)
  end

  object :countries_edge do
    field :cursor, non_null(:string)
    field :node, :country
  end

end
