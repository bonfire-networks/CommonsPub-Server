defmodule Geolocation.GraphQL.Hydration do
  alias MoodleNetWeb.GraphQL.{
    ActorsResolver,
    CommonResolver
  }

  alias MoodleNet.Communities.Community
  alias MoodleNet.Collections.Collection

  alias Organisation

  def hydrate() do
    %{
      testing_hydrations: [ resolve_type: &__MODULE__.resolve_context_type/2 ],
      spatial_thing: %{
        canonical_url: [
          resolve: &ActorsResolver.canonical_url_edge/3
        ],
        display_username: [
          resolve: &ActorsResolver.display_username_edge/3
        ],
        in_scope_of: [
          resolve: &CommonResolver.context_edge/3
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
        ],
        update_spatial_thing: [
          resolve: &Geolocation.GraphQL.update_geolocation/2
        ]
      },
      geo_scope: [
        resolve_type: &__MODULE__.resolve_context_type/2
      ],
    }
  end

  def resolve_context_type(%Community{}, _), do: :community
  def resolve_context_type(%Collection{}, _), do: :collection
  def resolve_context_type(%Organisation{}, _), do: :organisation
  def resolve_context_type(%{}, _), do: :community
end
