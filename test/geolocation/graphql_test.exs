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
      assert_geolocation(grumble_post_key(q, conn, :geolocation, %{id: geo.id}))
    end
  end

  describe "geolocation.context" do
    test "returns the context of the geolocation" do
      user = fake_user!()
      comm = fake_community!(user)
      geo = fake_geolocation!(user, comm)

      q = geolocation_query(fields: [in_scope_of: [:__typename]])
      conn = user_conn(user)
      assert resp = grumble_post_key(q, conn, :geolocation, %{id: geo.id})
      assert resp["context"]["__typename"] == "Community"
    end

    test "returns nil if there is no context" do
      user = fake_user!()
      geo = fake_geolocation!(user)

      q = geolocation_query(fields: [in_scope_of: [:__typename]])
      conn = user_conn(user)
      assert resp = grumble_post_key(q, conn, :geolocation, %{id: geo.id})
      assert is_nil(resp["context"])
    end
  end

  describe "geolocation.creator" do
  end

  describe "geolocations" do

  end

  describe "create_geolocation" do

  end

  describe "update_geolocation" do

  end

  describe "delete_geolocation" do

  end
end
