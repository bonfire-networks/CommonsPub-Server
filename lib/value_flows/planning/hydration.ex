defmodule ValueFlows.Planning.Hydration do

    alias MoodleNetWeb.GraphQL.{
      ActorsResolver
    }

    def hydrate(blueprint) do
      %{
        # spatial_thing: %{
        #   canonical_url: [
        #     resolve: &ActorsResolver.canonical_url_edge/3
        #   ],
        #   display_username: [
        #     resolve: &ActorsResolver.display_username_edge/3
        #   ],
        #   in_scope_of: [
        #     resolve: &Geolocation.GraphQL.community_edge/3
        #   ],
        # },
        planning_query: %{
          intent: [
            resolve: &ValueFlows.Planning.GraphQL.intent/2
          ],
          all_intents: [
            resolve: &ValueFlows.Planning.GraphQL.all_intents/3
          ]
        },
        planning_mutation: %{
          create_intent: [
            resolve: &ValueFlows.Planning.GraphQL.create_intent/2
          ]
        }
      }
    end

end
