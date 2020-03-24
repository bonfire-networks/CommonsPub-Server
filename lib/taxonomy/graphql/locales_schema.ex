# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Taxonomy.GraphQL.LocalesSchema do
  @moduledoc "GraphQL languages and countries"

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver}
  alias Taxonomy.GraphQL.{LocalesResolver}

  object :locales_queries do

    @desc "Get list of languages we know about"
    field :languages, non_null(:languages_nodes) do
      arg :limit, :integer
      arg :before, :string
      arg :after, :string
      resolve &LocalesResolver.languages/2
    end

    # field :language, :language do
    #   arg :language_id, non_null(:string)
    #   resolve &LocalesResolver.language/2
    # end

  #   field :search_language, non_null(:languages_nodes) do
  #     arg :query, non_null(:string)
  #     resolve &LocalesResolver.search_language/2
  #   end

  #   @desc "Get list of languages we know about"
  #   field :countries, non_null(:countries_nodes) do
  #     arg :limit, :integer
  #     arg :before, :string
  #     arg :after, :string
  #     resolve &LocalesResolver.countries/2
  #   end

  #   field :country, :country do
  #     arg :country_id, non_null(:string)
  #     resolve &LocalesResolver.country/2
  #   end

  #   field :search_country, :countries_nodes do
  #     arg :query, non_null(:string)
  #     resolve &LocalesResolver.search_country/2
  #   end

  end

  object :language do
    field(:id, :string)
    field(:main_name, :string)
    field(:sub_name, :string)
    field(:native_name, :string)
    field(:language_type, :string)
    field(:parent_language_id, :string)
    field(:main_country_id, :string)
    field(:speakers_mil, :float)
    field(:speakers_native, :float)
    field(:speakers_native_total, :float)
    field(:rtl, :boolean)
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

  # object :country do
  #   field :id, :string
  #   field :iso_code2, :string
  #   field :iso_code3, :string
  #   field :english_name, :string
  #   field :local_name, :string
  #   field :created_at, :string do
  #     resolve &CommonResolver.created_at/3
  #   end
  #   field :updated_at, :string
  # end

  # object :countries_nodes do
  #   field :page_info, non_null(:page_info)
  #   field :nodes, list_of(:country)
  #   field :total_count, non_null(:integer)
  # end

  # object :countries_edges do
  #   field :page_info, non_null(:page_info)
  #   field :edges, list_of(:countries_edge)
  #   field :total_count, non_null(:integer)
  # end

  # object :countries_edge do
  #   field :cursor, non_null(:string)
  #   field :node, :country
  # end

end
