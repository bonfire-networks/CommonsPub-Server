# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ResourcesTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNet.Test.Fake
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import MoodleNet.Test.Faking
  alias MoodleNet.{Access, Repo, Users}

  describe "resource" do
    test "works for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      q = """
      { resource(resourceId: "#{res.id}") { #{resource_basics()} } }
      """
      query = %{query: q}
      assert %{"resource" => res2} = gql_post_data(query)
      res2 = assert_resource(res, res2)
      assert res2.is_public == true
      assert res2.is_disabled == false
      assert res2.is_local == true
    end
  end
  describe "createResource" do

    test "works for a user" do
      alice = fake_user!()
      bob = fake_user!()
      conn = user_conn(bob)
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      ri = Fake.resource_input()
      q = """
      mutation Test($resource: ResourceInput!) {
        createResource(collectionId: "#{coll.id}", resource: $resource) {
	  #{resource_basics()}
        }
      }
      """
      query = %{query: q, operation: "Test", variables: %{"resource" => ri}}
      assert %{"createResource" => res} = gql_post_data(conn, query)
      res = assert_resource(res)
      assert res.name == ri["name"]
      assert res.summary == ri["summary"]
      assert res.icon == ri["icon"]
      assert res.url == ri["url"]
      assert res.license == ri["license"]
      assert res.is_public == true
      assert res.is_disabled == false
      assert res.is_local == true
    end

    test "does not work for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      ri = Fake.resource_input()
      q = """
      mutation Test($resource: ResourceInput!) {
        createResource(collectionId: "#{coll.id}", resource: $resource) {
	  #{resource_basics()}
        }
      }
      """
      query = %{query: q, operation: "Test", variables: %{"resource" => ri}}
      assert_not_logged_in(gql_post_errors(query), ["createResource"])
    end
  end
  describe "updateResource" do

    test "works for the resource creator" do
      alice = fake_user!()
      bob = fake_user!()
      conn = user_conn(bob)
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      resource = fake_resource!(bob, coll)
      ri = Fake.resource_input()
      q = """
      mutation Test($resource: ResourceInput!) {
        updateResource(resourceId: "#{resource.id}", resource: $resource) {
	  #{resource_basics()}
        }
      }
      """
      query = %{query: q, operation: "Test", variables: %{"resource" => ri}}
      assert %{"updateResource" => res} = gql_post_data(conn, query)
      res = assert_resource(res)
      assert res.name == ri["name"]
      assert res.summary == ri["summary"]
      assert res.icon == ri["icon"]
      assert res.url == ri["url"]
      assert res.license == ri["license"]
      assert res.is_public == true
      assert res.is_disabled == false
      assert res.is_local == true
    end

    test "works for the collection creator" do
      alice = fake_user!()
      bob = fake_user!()
      conn = user_conn(bob)
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      resource = fake_resource!(alice, coll)
      ri = Fake.resource_input()
      q = """
      mutation Test($resource: ResourceInput!) {
        updateResource(resourceId: "#{resource.id}", resource: $resource) {
	  #{resource_basics()}
        }
      }
      """
      query = %{query: q, operation: "Test", variables: %{"resource" => ri}}
      assert %{"updateResource" => res} = gql_post_data(conn, query)
      res = assert_resource(res)
      assert res.name == ri["name"]
      assert res.summary == ri["summary"]
      assert res.icon == ri["icon"]
      assert res.url == ri["url"]
      assert res.license == ri["license"]
      assert res.is_public == true
      assert res.is_disabled == false
      assert res.is_local == true
    end

    test "works for the community creator" do
      alice = fake_user!()
      bob = fake_user!()
      conn = user_conn(bob)
      comm = fake_community!(bob)
      coll = fake_collection!(alice, comm)
      resource = fake_resource!(alice, coll)
      ri = Fake.resource_input()
      q = """
      mutation Test($resource: ResourceInput!) {
        updateResource(resourceId: "#{resource.id}", resource: $resource) {
	  #{resource_basics()}
        }
      }
      """
      query = %{query: q, operation: "Test", variables: %{"resource" => ri}}
      assert %{"updateResource" => res} = gql_post_data(conn, query)
      res = assert_resource(res)
      assert res.name == ri["name"]
      assert res.summary == ri["summary"]
      assert res.icon == ri["icon"]
      assert res.url == ri["url"]
      assert res.license == ri["license"]
      assert res.is_public == true
      assert res.is_disabled == false
      assert res.is_local == true
    end

    test "does not work for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      resource = fake_resource!(alice, coll)
      ri = Fake.resource_input()
      q = """
      mutation Test($resource: ResourceInput!) {
        updateResource(resourceId: "#{resource.id}", resource: $resource) {
	  #{resource_basics()}
        }
      }
      """
      query = %{query: q, operation: "Test", variables: %{"resource" => ri}}
      assert_not_logged_in(gql_post_errors(query), ["updateResource"])
    end
  end

  describe "copyResource" do
    test "works for a user" do
      alice = fake_user!()
      bob = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      coll2 = fake_collection!(alice, comm)
      conn = user_conn(bob)
      resource = fake_resource!(alice, coll)
      q = """
      mutation Test {
        copyResource(resourceId: "#{resource.id}", collectionId: "#{coll2.id}") {
	  #{resource_basics()}
        }
      }
      """
      query = %{query: q, operation: "Test"}
      assert %{"copyResource" => res} = gql_post_data(conn, query)
      res = assert_resource(res)
      assert resource.name == res.name
      assert resource.summary == res.summary
      assert resource.icon == res.icon
      assert resource.url == res.url
      assert resource.license == res.license
    end

    test "does not work for a guest" do
      alice = fake_user!()
      bob = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      coll2 = fake_collection!(alice, comm)
      resource = fake_resource!(alice, coll)
      q = """
      mutation Test {
        copyResource(resourceId: "#{resource.id}", collectionId: "#{coll2.id}") {
	  #{resource_basics()}
        }
      }
      """
      query = %{query: q, operation: "Test"}
      assert_not_logged_in(gql_post_errors(query), ["copyResource"])
    end
  end

  describe "delete (via common)" do
    @tag :skip
    test "works for creator" do
    end
    @tag :skip
    test "works for collection creator" do
    end
    @tag :skip
    test "works for community creator" do
    end
    @tag :skip
    test "works for admin" do
    end
    @tag :skip
    test "doesn't work for random" do
    end
    @tag :skip
    test "doesn't work for guest" do
    end
  end
  describe "follow (via common)" do
    @tag :skip
    test "does not work" do
    end
  end
  describe "resource.myLike" do
    @tag :skip
    test "placeholder" do
    end
  end
  describe "resource.creator" do
    @tag :skip
    test "placeholder" do
    end
  end
  describe "resource.collection" do
    @tag :skip
    test "placeholder" do
    end
  end
  describe "resource.likes" do
    @tag :skip
    test "placeholder" do
    end
  end
  describe "resource.flags" do
    @tag :skip
    test "placeholder" do
    end
  end

end
