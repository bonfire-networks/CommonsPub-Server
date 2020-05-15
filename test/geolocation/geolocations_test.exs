# SPDX-License-Identifier: AGPL-3.0-only
defmodule Geolocation.GeolocationsTest do
  use MoodleNetWeb.ConnCase, async: true

  import MoodleNet.Test.Faking
  import Geolocation.Test.Faking
  alias Geolocation.Geolocations

  describe "one" do
  end

  describe "create" do
    test "creates a new geolocation" do
      user = fake_user!()

      assert {:ok, geo} = Geolocations.create(user, geolocation())
      assert_geolocation(geo)
    end

    test "creates a new geolocation with a context" do
      user = fake_user!()
      comm = fake_community!(user)

      assert {:ok, geo} = Geolocations.create(user, comm, geolocation())
      assert_geolocation(geo)
      assert geo.context_id == comm.id
    end
  end
end
