# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Schema do
  use Absinthe.Schema.Notation
  # alias MoodleNetWeb.GraphQL.{CommonResolver}
  require Logger

  import_types(Absinthe.Type.Custom)
  import_sdl(path: "lib/extensions/value_flows/schema.gql")

  @desc "A page of intents"
  object :intents_page do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(non_null(:intent))))
    field(:total_count, non_null(:integer))
  end

  @desc "A page of proposals"
  object :proposals_page do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(non_null(:proposal))))
    field(:total_count, non_null(:integer))
  end

  @desc "A page of agents"
  object :agents_page do
    field(:page_info, non_null(:page_info))
    field(:edges, non_null(list_of(non_null(:agent))))
    field(:total_count, non_null(:integer))
  end

  object :value_flows_extra_queries do
    @desc "Get paginated list of proposals"
    field :proposals_pages, non_null(:proposals_page) do
      # arg(:in_scope_of, :id)
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&ValueFlows.Proposal.GraphQL.proposals/2)
    end

    @desc "Get paginated list of intents"
    field :intents_pages, non_null(:intents_page) do
      # arg(:in_scope_of, :id)
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&ValueFlows.Planning.Intent.GraphQL.intents/2)
    end

    @desc "TEMPORARY - get filtered but non-paginated list of intents"
    field :intents_filter, list_of(:intent) do
      arg(:in_scope_of, list_of(:id))

      arg(:tag_ids, list_of(:id))

      arg(:at_location, list_of(:id))

      arg(:geolocation, :geolocation_filters)

      arg(:agent, list_of(:id))
      arg(:provider, list_of(:id))
      arg(:receiver, list_of(:id))

      arg(:action, list_of(:id))

      resolve(&ValueFlows.Planning.Intent.GraphQL.intents_filtered/2)
    end

    #   intents(start: ID, limit: Int): [Intent!]

    @desc "Get paginated list of active offers (intents no receiver)"
    field :offers_pages, non_null(:intents_page) do
      # arg(:in_scope_of, :id)
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&ValueFlows.Planning.Intent.GraphQL.offers/2)
    end

    @desc "Get paginated list of active needs (intents no provider)"
    field :needs_pages, non_null(:intents_page) do
      # arg(:in_scope_of, :id)
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&ValueFlows.Planning.Intent.GraphQL.needs/2)
    end

    # @desc "Get paginated list of agents"
    # field :agents_pages, non_null(:agents_page) do
    #   arg :limit, :integer
    #   arg :before, list_of(non_null(:cursor))
    #   arg :after, list_of(non_null(:cursor))
    #   resolve &ValueFlows.Planning.Intent.GraphQL.agents/2
    # end

    @desc "Get paginated list of people"
    field :people_pages, non_null(:agents_page) do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&ValueFlows.Agent.GraphQL.people/2)
    end

    @desc "Get paginated list of organizations"
    field :organizations_pages, non_null(:agents_page) do
      arg(:limit, :integer)
      arg(:before, list_of(non_null(:cursor)))
      arg(:after, list_of(non_null(:cursor)))
      resolve(&ValueFlows.Agent.GraphQL.organizations/2)
    end
  end
end
