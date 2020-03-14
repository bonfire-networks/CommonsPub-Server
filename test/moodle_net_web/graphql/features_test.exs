# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.FeaturesTest do
  use MoodleNetWeb.ConnCase, async: true

  import MoodleNet.Test.Faking
  import MoodleNetWeb.Test.ConnHelpers
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields

  alias MoodleNet.Features

  describe "feature" do
    test "works for a guest for a feature" do
      user = fake_user!()
      comm = fake_community!(user)

      assert {:ok, feature} = Features.create(user, comm, %{is_local: true})

      q = """
      {
        feature(featureId: "#{feature.id}") {
          #{feature_basics()}
        }
      }
      """
      assert %{"feature" => fetched} = gql_post_data(%{query: q})
      assert fetched["id"] == feature.id
    end

    test "works for a logged in user" do
      user = fake_user!()
      conn = user_conn(user)
      comm = fake_community!(user)
      coll = fake_collection!(user, comm)

      assert {:ok, feature} = Features.create(user, coll, %{is_local: true})

      q = """
      {
        feature(featureId: "#{feature.id}") {
          #{feature_basics()}
        }
      }
      """
      assert %{"feature" => _} = gql_post_data(conn, %{query: q})
    end
  end

  describe "feature.creator" do
    test "returns the feature creator" do
      user = fake_user!()
      comm = fake_community!(user)

      assert {:ok, feature} = Features.create(user, comm, %{is_local: true})

      q = """
      {
        feature(featureId: "#{feature.id}") {
          #{feature_basics()}
          creator { #{user_basics()} }
        }
      }
      """
      assert %{"feature" => fetched} = gql_post_data(%{query: q})
      assert %{"creator" => creator} = fetched
      assert_user(user, creator)
    end
  end

  describe "feature.context" do
    test "returns the feature context" do
      user = fake_user!()
      comm = fake_community!(user)

      assert {:ok, feature} = Features.create(user, comm, %{is_local: true})

      q = """
      {
        feature(featureId: "#{feature.id}") {
          #{feature_basics()}
          context { ... on Community { #{community_basics()} } }
        }
      }
      """
      assert %{"feature" => fetched} = gql_post_data(%{query: q})
      assert %{"context" => context} = fetched
      assert_community(comm, context)
    end
  end

  describe "createFeature" do
    test "works for an admin" do
      user = fake_user!(%{is_instance_admin: true})
      conn = user_conn(user)
      comm = fake_community!(user)

      q = """
      mutation Test {
        createFeature(contextId: "#{comm.id}") {
          #{feature_basics()}
        }
      }
      """

      assert %{"createFeature" => feature} = gql_post_data(conn, %{query: q, mutation: "Test"})
      assert feature["id"]

      assert {:ok, _} = Features.one(context_id: comm.id)
    end

    test "fails for a normal user" do
      user = fake_user!()
      conn = user_conn(user)
      comm = fake_community!(user)

      q = """
      mutation Test {
        createFeature(contextId: "#{comm.id}") {
          #{feature_basics()}
        }
      }
      """

      assert [%{"code" => "unauthorized", "status" => 403}] = gql_post_errors(conn, %{query: q, mutation: "Test"})
    end
  end
end
