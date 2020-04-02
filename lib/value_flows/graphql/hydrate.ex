defmodule ValueFlows.GraphQL.Hydrate do

  alias MoodleNetWeb.GraphQL.{
    ActorsResolver
  }

  def hydrate(blueprint) do
    %{
      spatial_thing: %{
        canonical_url: [
          resolve: &ActorsResolver.canonical_url_edge/3
        ],
        display_username: [
          resolve: &ActorsResolver.display_username_edge/3
        ],
        community: [
          resolve: &ValueFlows.Geolocation.GraphQL.community_edge/3
        ],
      },
      geolocation_query: %{
        spatial_thing: [
          resolve: &ValueFlows.Geolocation.GraphQL.geolocation/2
        ],
        spatial_things: [
          resolve: &ValueFlows.Geolocation.GraphQL.geolocations/2
        ]
      },
      measurement_query: %{
        all_units: [
          resolve: &ValueFlows.Measurement.GraphQL.all_units/3
        ],
        unit: [
          resolve: &ValueFlows.Measurement.GraphQL.unit/2
        ]
      },
      agent_query: %{
        all_agents: [
          resolve: &ValueFlows.Agent.GraphQL.all_agents/3
        ],
        agent_query: [
          resolve: &ValueFlows.Agent.GraphQL.agent/2
        ]
      },
      planning_query: %{
        all_intents: [
          resolve: &ValueFlows.Planning.GraphQL.all_intents/3
        ],
        intent: [
          resolve: &ValueFlows.Planning.GraphQL.intent/2
        ]
      },
      # mutation: %{
      #   failing_thing: [
      #     resolve: &__MODULE__.resolve_failing_thing/3
      #   ]
      # }
    }
  end




end