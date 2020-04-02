defmodule Geolocation.GraphQL.Hydration do

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
        in_scope_of: [
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
      # mutation: %{
      #   failing_thing: [
      #     resolve: &__MODULE__.resolve_failing_thing/3
      #   ]
      # }
    }
  end




end