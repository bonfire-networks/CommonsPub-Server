# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Schema do

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver}
  require Logger

  import_types Absinthe.Type.Custom
  import_sdl path: "lib/value_flows/schema.gql"

  @desc "A page of intents"
  object :intents_page do
    field :page_info, non_null(:page_info)
    field :edges, non_null(list_of(non_null(:intent)))
    field :total_count, non_null(:integer)
  end

  @desc "A page of agents"
  object :agents_page do
    field :page_info, non_null(:page_info)
    field :edges, non_null(list_of(non_null(:agent)))
    field :total_count, non_null(:integer)
  end

  object :value_flows_extra_queries do

    @desc "Get paginated list of intents"
    field :intents_pages, non_null(:intents_page) do
      arg :limit, :integer
      arg :before, list_of(non_null(:cursor))
      arg :after, list_of(non_null(:cursor))
      resolve &ValueFlows.Planning.Intent.GraphQL.all_intents/2
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
      arg :limit, :integer
      arg :before, list_of(non_null(:cursor))
      arg :after, list_of(non_null(:cursor))
      resolve &ValueFlows.Agent.GraphQL.people/2
    end

    @desc "Get paginated list of organizations"
    field :organizations_pages, non_null(:agents_page) do
      arg :limit, :integer
      arg :before, list_of(non_null(:cursor))
      arg :after, list_of(non_null(:cursor))
      resolve &ValueFlows.Agent.GraphQL.organizations/2
    end

  end


end
