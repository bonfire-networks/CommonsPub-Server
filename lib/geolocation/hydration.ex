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
          resolve: &Geolocation.GraphQL.community_edge/3
        ],
      },
      geolocation_query: %{
        spatial_thing: [
          resolve: &Geolocation.GraphQL.geolocation/2
        ],
        spatial_things_pages: [
          resolve: &Geolocation.GraphQL.geolocations/2
        ]
      },
      geolocation_mutation: %{
        create_spatial_thing: [
          resolve: &Geolocation.GraphQL.create_geolocation/2
        ]
      }
    }
  end




end