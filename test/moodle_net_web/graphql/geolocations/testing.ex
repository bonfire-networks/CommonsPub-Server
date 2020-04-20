defmodule MoodleNetWeb.GraphQL.Geolocation.Testing do

    import MoodleNetWeb.Test.GraphQLAssertions
    import MoodleNetWeb.Test.GraphQLFields
    alias Geolocation

### Graphql fields

  def geolocation_subquery(options \\ []) do
    gen_subquery(:id, :spatial_thing, &geolocation_fields/1, options)
  end

  def geolocation_query(options \\ []) do
    gen_query(:id, &geolocation_subquery/1, options)
  end

  def geolocation_fields(extra \\ []) do
    extra ++ ~w(id name mappable_address lat long alt note canonical_url display_username __typename)a
  end

### Geolocation assertion

def assert_geolocation(geo) do
    assert_object geo, :assert_geolocation,
      [id: &assert_ulid/1,
       canonical_url: assert_optional(&assert_url/1),
       display_username: &assert_display_username/1,
       name: &assert_binary/1,
       note: &assert_binary/1,
       mappable_address: assert_optional(&assert_binary/1),
       lat: assert_optional(&assert_binary/1),
       long: assert_optional(&assert_binary/1),
       alt: assert_optional(&assert_binary/1),

       typename: assert_eq("SpatialThing"),
      ]
  end

  def assert_geolocation(%Geolocation{}=geo, %{id: _}=geo2) do
    assert_geolocations_eq(geo, geo2)
  end

  def assert_geolocation(%Geolocation{}=geo, %{}=geo2) do
    assert_geolocations_eq(geo, assert_geolocation(geo2))
  end


  def assert_geolocations_eq(%Geolocation{}=geo, %{}=geo2) do
    assert_maps_eq geo, geo2, :assert_geolocation,
      [:id, :canonical_url, :note, :mappable_address, :display_username, :name, :alt, :lat, :long]
    geo2
  end

end
