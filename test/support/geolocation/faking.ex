# Based on code from MoodleNet
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Geolocation.Test.Faking do
  @moduledoc false

  import Grumble
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  alias MoodleNet.Test.Fake
  alias Geolocation.Geolocations

  ## Geolocation

  def mappable_address do
    # guaranteed random
    "1221 Williamson St., Madison, WI 53703"
  end

  def geolocation(base \\ %{}) do
    base
    |> Map.put_new_lazy(:name, &Fake.name/0)
    |> Map.put_new_lazy(:note, &Fake.summary/0)
    |> Map.put_new_lazy(:lat, &Faker.Address.latitude/0)
    |> Map.put_new_lazy(:long, &Faker.Address.longitude/0)
    |> Map.put_new_lazy(:is_public, &Fake.truth/0)
    |> Map.put_new_lazy(:is_disabled, &Fake.falsehood/0)
    |> Map.merge(Fake.actor(base))
  end

  def geolocation_input(base \\ %{}) do
    base
    |> Map.put_new_lazy("name", &Fake.name/0)
    |> Map.put_new_lazy("note", &Fake.summary/0)
    |> Map.put_new_lazy("lat", &Faker.Address.latitude/0)
    |> Map.put_new_lazy("long", &Faker.Address.longitude/0)
    |> Map.put_new_lazy("alt", &Fake.pos_integer/0)
  end

  def fake_geolocation!(user, context \\ nil, overrides  \\ %{})

  def fake_geolocation!(user, context, overrides) when is_nil(context) do
    {:ok, geolocation} = Geolocations.create(user, geolocation(overrides))
    geolocation
  end

  def fake_geolocation!(user, context, overrides) do
    {:ok, geolocation} = Geolocations.create(user, context, geolocation(overrides))
    geolocation
  end


  ## assertions

  def assert_geolocation(%Geolocation{} = geo) do
    assert_geolocation(Map.from_struct(geo))
  end

  def assert_geolocation(geo) do
    assert_object geo, :assert_geolocation,
      [id: &assert_ulid/1,
       name: &assert_binary/1,
       note: assert_optional(&assert_binary/1),
       lat: assert_optional(&assert_float/1),
       long: assert_optional(&assert_float/1),
      ]
  end

  ## graphql queries

  def geolocation_query_fields(extra \\ []) do
    extra ++ ~w(id name mappable_address lat long alt note geom)a
  end

  def geolocation_mutation_fields(extra \\ []) do
    [spatial_thing: extra ++ ~w(id name mappable_address lat long alt note geom)a]
  end

  def geolocation_query(options \\ []) do
    options = Keyword.put_new(options, :id_type, :id)
    gen_query(:id, &geolocation_subquery/1, options)
  end

  def geolocation_subquery(options \\ []) do
    gen_subquery(:id, :spatial_thing, &geolocation_query_fields/1, options)
  end

  def create_geolocation_mutation(options \\ []) do
    [spatial_thing: type!(:spatial_thing_input)]
    |> gen_mutation(&create_geolocation_submutation/1, options)
  end

  def create_geolocation_submutation(options \\ []) do
    [spatial_thing: var(:spatial_thing)]
    |> gen_submutation(:create_spatial_thing, &geolocation_mutation_fields/1, options)
  end

  def update_geolocation_mutation(options \\ []) do
    [spatial_thing: type!(:spatial_thing_input)]
    |> gen_mutation(&update_geolocation_submutation/1, options)
  end

  def update_geolocation_submutation(options \\ []) do
    [spatial_thing: var(:spatial_thing)]
    |> gen_submutation(:update_spatial_thing, &geolocation_mutation_fields/1, options)
  end

  def delete_geolocation_mutation(options \\ []) do
    [id: type!(:id)]
    |> gen_mutation(&delete_geolocation_submutation/1, options)
  end

  def delete_geolocation_submutation(_options \\ []) do
    field(:delete_spatial_thing, args: [id: var(:id)])
  end
end
