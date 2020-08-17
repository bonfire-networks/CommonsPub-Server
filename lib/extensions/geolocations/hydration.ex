defmodule Geolocation.GraphQL.Hydration do
  alias MoodleNetWeb.GraphQL.{
    CommonResolver
  }

  alias MoodleNet.Communities.Community
  alias MoodleNet.Collections.Collection

  alias Organisation

  def hydrate() do
    %{
      spatial_thing: %{
        canonical_url: [
          resolve: &CommonsPub.Character.GraphQL.Resolver.canonical_url_edge/3
        ],
        display_username: [
          resolve: &CommonsPub.Character.GraphQL.Resolver.display_username_edge/3
        ],
        in_scope_of: [
          resolve: &CommonResolver.context_edge/3
        ]
      },
      geolocation_query: %{
        spatial_thing: [
          resolve: &Geolocation.GraphQL.geolocation/2
        ],
        spatial_things_pages: [
          resolve: &Geolocation.GraphQL.geolocations/2
        ],
        spatial_things: [
          resolve: &Geolocation.GraphQL.all_geolocations/2
        ]
      },
      geolocation_mutation: %{
        create_spatial_thing: [
          resolve: &Geolocation.GraphQL.create_geolocation/2
        ],
        update_spatial_thing: [
          resolve: &Geolocation.GraphQL.update_geolocation/2
        ],
        delete_spatial_thing: [
          resolve: &Geolocation.GraphQL.delete_geolocation/2
        ]
      }
      # geo_scope: [
      #   resolve_type: &CommonResolver.resolve_context_type/2
      # ]
    }
  end
end
