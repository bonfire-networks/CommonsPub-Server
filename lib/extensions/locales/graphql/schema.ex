# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Locales.GraphQL.Schema do
  @moduledoc "GraphQL languages and countries"

  use Absinthe.Schema.Notation
  # alias CommonsPub.Web.GraphQL.{CommonResolver}
  alias CommonsPub.Locales.GraphQL.{Resolver}

  object :locales_queries do
    @desc "Get list of languages we know about"
    field :languages, non_null(:languages_page) do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&Resolver.languages/2)
    end

    field :language, :language do
      arg(:language_id, non_null(:string))
      resolve(&Resolver.language/2)
    end

    @desc "Get list of countries we know about"
    field :countries, non_null(:countries_pages) do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&Resolver.countries/2)
    end

    field :country, :country do
      arg(:country_id, non_null(:string))
      resolve(&Resolver.country/2)
    end
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
    field(:speakers_native, :integer)
    field(:speakers_native_total, :integer)
    field(:rtl, :boolean)
  end

  object :languages_page do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(non_null(:language))))
    field(:total_count, non_null(:integer))
  end

  object :country do
    field(:id, :string)
    field(:id_3letter, :string)
    field(:id_iso, :string)

    field(:name_eng, :string)
    field(:name_local, :string)
    field(:name_eng_formal, :string)

    field(:population, :integer)
    field(:capital, :string)
    field(:tld, :string)
    field(:tel_prefix, :string)

    # these all should use resolvers
    field(:continent_id, :string)
    field(:language_main, :string)
    field(:currency_id, :string)
    field(:main_tz, :string)
  end

  object :countries_pages do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(non_null(:country))))
    field(:total_count, non_null(:integer))
  end

  # object :localisation_queries do

  #   @desc "Get list of languages we know about"
  #   field :languages, non_null(:languages_page) do
  #     arg :limit, :integer
  #     arg :before, list_of(non_null(:cursor))
  #     arg :after, list_of(non_null(:cursor))
  #     resolve &LocalisationResolver.languages/2
  #   end

  #   field :language, :language do
  #     arg :language_id, non_null(:string)
  #     resolve &LocalisationResolver.language/2
  #   end

  #   field :search_language, non_null(:languages_page) do
  #     arg :query, non_null(:string)
  #     resolve &LocalisationResolver.search_language/2
  #   end

  #   @desc "Get list of languages we know about"
  #   field :countries, non_null(:countries_page) do
  #     arg :limit, :integer
  #     arg :before, list_of(non_null(:cursor))
  #     arg :after, list_of(non_null(:cursor))
  #     resolve &LocalisationResolver.countries/2
  #   end

  #   field :country, :country do
  #     arg :country_id, non_null(:string)
  #     resolve &LocalisationResolver.country/2
  #   end

  #   field :search_country, :countries_page do
  #     arg :query, non_null(:string)
  #     resolve &LocalisationResolver.search_country/2
  #   end
  # end

  # object :language do
  #   field :id, :string
  #   field :iso_code2, :string
  #   field :iso_code3, :string
  #   field :english_name, :string
  #   field :local_name, :string
  #   field :created_at, :string do
  #   resolve &CommonResolver.created_at/3
  # end
  #   field :updated_at, :string
  # end

  # object :languages_page do
  #   field :page_info, non_null(:page_info)
  #   field :edges, non_null(list_of(:language))
  #   field :total_count, non_null(:integer)
  # end

  # object :country do
  #   field :id, :string
  #   field :iso_code2, :string
  #   field :iso_code3, :string
  #   field :english_name, :string
  #   field :local_name, :string
  #   field :created_at, :string do
  #   resolve &CommonResolver.created_at/3
  # end
  #   field :updated_at, :string
  # end

  # object :countries_page do
  #   field :page_info, non_null(:page_info)
  #   field :edges, non_null(list_of(:country))
  #   field :total_count, non_null(:integer)
  # end
end
