# SPDX-License-Identifier: AGPL-3.0-only
defmodule Geolocation.GraphQLTest do
  use MoodleNetWeb.ConnCase, async: true

  import MoodleNet.Test.Faking
  import Geolocation.Test.Faking
  alias Geolocation.Geolocations

  describe "geolocation" do
    test "fetches a geolocation by ID" do
      user = fake_user!()
      geo = fake_geolocation!(user)

      q = geolocation_query()
      conn = user_conn(user)
      assert_geolocation(grumble_post_key(q, conn, :spatial_thing, %{id: geo.id}))
    end
  end

  describe "geolocation.in_scope_of" do
    test "returns the context of the geolocation" do
      user = fake_user!()
      comm = fake_community!(user)
      geo = fake_geolocation!(user, comm)

      q = geolocation_query(fields: [in_scope_of: [:__typename]])
      conn = user_conn(user)
      assert resp = grumble_post_key(q, conn, :spatial_thing, %{id: geo.id})
      assert resp["inScopeOf"]["__typename"] == "Community"
    end

    test "returns nil if there is no context" do
      user = fake_user!()
      geo = fake_geolocation!(user)

      q = geolocation_query(fields: [in_scope_of: [:__typename]])
      conn = user_conn(user)
      assert resp = grumble_post_key(q, conn, :spatial_thing, %{id: geo.id})
      assert is_nil(resp["context"])
    end
  end

  describe "geolocations" do
  end

  describe "create_geolocation" do
    test "creates a new geolocation" do
      user = fake_user!()

      q = create_geolocation_mutation()
      conn = user_conn(user)
      vars = %{spatial_thing: geolocation_input()}
      assert_geolocation(grumble_post_key(q, conn, :create_spatial_thing, vars))
    end

    test "creates a new geolocation with a context" do
      user = fake_user!()
      comm = fake_community!(user)

      q = create_geolocation_mutation(fields: [in_scope_of: [:__typename]])
      conn = user_conn(user)
      vars = %{spatial_thing: geolocation_input(), in_scope_of: comm.id}
      assert_geolocation(grumble_post_key(q, conn, :create_spatial_thing, vars))
    end
  end

  describe "update_geolocation" do
    test "updates an existing geolocation" do
      user = fake_user!()
      geo = fake_geolocation!(user)

      q = update_geolocation_mutation()
      conn = user_conn(user)
      vars = %{spatial_thing: geolocation_input()}
      assert_geolocation(grumble_post_key(q, conn, :update_spatial_thing, vars))
    end
  end
end
