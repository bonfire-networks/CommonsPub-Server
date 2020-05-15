# Based on code from MoodleNet
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Geolocation.Test.Faking do
  @moduledoc false

  import MoodleNetWeb.Test.GraphQLAssertions
  alias MoodleNet.Test.Fake
  alias Geolocation.Geolocations

  ## Geolocation

  def geolocation(base \\ %{}) do
    base
    |> Map.put_new_lazy(:name, &Fake.name/0)
    |> Map.put_new_lazy(:note, &Fake.summary/0)
    |> Map.put_new_lazy(:lat, &Fake.integer/0)
    |> Map.put_new_lazy(:long, &Fake.integer/0)
    |> Map.put_new_lazy(:is_public, &Fake.truth/0)
    |> Map.put_new_lazy(:is_disabled, &Fake.falsehood/0)
    |> Map.merge(Fake.actor(base))
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
       published_at: assert_optional(&assert_datetime/1),
       disabled_at: assert_optional(&assert_datetime/1),
       deleted_at: assert_optional(&assert_datetime/1),
      ]
  end
end
