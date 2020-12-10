defmodule Bonfire.Geolocate.GraphQL.Hydration do
  alias CommonsPub.Web.GraphQL.CommonResolver

  def hydrate() do
    %{
      spatial_thing: %{
        canonical_url: [
          resolve: &CommonsPub.Characters.GraphQL.Resolver.canonical_url_edge/3
        ],
        display_username: [
          resolve: &CommonsPub.Characters.GraphQL.Resolver.display_username_edge/3
        ],
        in_scope_of: [
          resolve: &CommonResolver.context_edge/3
        ]
      },
      geolocation_query: %{
        spatial_thing: [
          resolve: &Bonfire.Geolocate.GraphQL.geolocation/2
        ],
        spatial_things_pages: [
          resolve: &Bonfire.Geolocate.GraphQL.geolocations/2
        ],
        spatial_things: [
          resolve: &Bonfire.Geolocate.GraphQL.all_geolocations/2
        ]
      },
      geolocation_mutation: %{
        create_spatial_thing: [
          resolve: &Bonfire.Geolocate.GraphQL.create_geolocation/2
        ],
        update_spatial_thing: [
          resolve: &Bonfire.Geolocate.GraphQL.update_geolocation/2
        ],
        delete_spatial_thing: [
          resolve: &Bonfire.Geolocate.GraphQL.delete_geolocation/2
        ]
      }
      # geo_scope: [
      #   resolve_type: &CommonResolver.resolve_context_type/2
      # ]
    }
  end
end
