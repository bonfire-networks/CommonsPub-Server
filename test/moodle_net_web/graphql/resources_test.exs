# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ResourcesTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNet.Test.Fake
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import MoodleNet.Test.Faking
  alias MoodleNet.{Flags, Likes, Resources}

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

    test "is nil for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()} myLike { #{like_basics()} }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(%{query: q})
      res2 = assert_resource(res, res2)
      assert %{"myLike" => nil} = res2
    end

    test "is nil for an instance admin who does not like it" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()} myLike { #{like_basics()} }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(conn, %{query: q})
      res2 = assert_resource(res, res2)
      assert %{"myLike" => nil} = res2
    end

    test "is nil for a user who does not like it" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      bob = fake_user!()
      conn = user_conn(bob)
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()} myLike { #{like_basics()} }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(conn, %{query: q})
      res2 = assert_resource(res, res2)
      assert %{"myLike" => nil} = res2
    end

    test "works for an instance admin who likes it" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      {:ok, like} = Likes.create(bob, res, %{is_local: true})
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()} myLike { #{like_basics()} }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(conn, %{query: q})
      res2 = assert_resource(res, res2)
      assert %{"myLike" => like2} = res2
      assert_like(like, like2)
    end

    test "works for a user who likes it" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      bob = fake_user!()
      conn = user_conn(bob)
      {:ok, like} = Likes.create(bob, res, %{is_local: true})
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()} myLike { #{like_basics()} }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(conn, %{query: q})
      res2 = assert_resource(res, res2)
      assert %{"myLike" => like2} = res2
      assert_like(like, like2)
    end
  end

  describe "resource.myFlag" do

    test "is nil for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()} myFlag { #{flag_basics()} }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(%{query: q})
      res2 = assert_resource(res, res2)
      assert %{"myFlag" => nil} = res2
    end

    test "is nil for an instance admin who does not flag it" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()} myFlag { #{flag_basics()} }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(conn, %{query: q})
      res2 = assert_resource(res, res2)
      assert %{"myFlag" => nil} = res2
    end

    test "is nil for a user who does not flag it" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      bob = fake_user!()
      conn = user_conn(bob)
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()} myFlag { #{flag_basics()} }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(conn, %{query: q})
      res2 = assert_resource(res, res2)
      assert %{"myFlag" => nil} = res2
    end

    test "works for an instance admin who flags it" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      {:ok, flag} = Flags.create(bob, res, %{is_local: true, message: "naughty"})
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()} myFlag { #{flag_basics()} }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(conn, %{query: q})
      res2 = assert_resource(res, res2)
      assert %{"myFlag" => flag2} = res2
      assert_flag(flag, flag2)
    end

    test "works for a user who flags it" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      bob = fake_user!()
      conn = user_conn(bob)
      {:ok, flag} = Flags.create(bob, res, %{is_local: true, message: "naughty"})
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()} myFlag { #{flag_basics()} }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(conn, %{query: q})
      res2 = assert_resource(res, res2)
      assert %{"myFlag" => flag2} = res2
      assert_flag(flag, flag2)
    end

  end

  describe "resource.creator" do

    test "works for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()} creator { #{user_basics()} }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(%{query: q})
      res2 = assert_resource(res, res2)
      assert %{"creator" => alice2} = res2
      assert_user(alice, alice2)
    end

    test "works for an instance admin" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()} creator { #{user_basics()} }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(conn, %{query: q})
      res2 = assert_resource(res, res2)
      assert %{"creator" => alice2} = res2
      assert_user(alice, alice2)
    end

    test "works for a user" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()} creator { #{user_basics()} }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(conn, %{query: q})
      res2 = assert_resource(res, res2)
      assert %{"creator" => alice2} = res2
      assert_user(alice, alice2)
    end

    @tag :skip
    test "does not work for a guest with a private user" do
    end

    @tag :skip
    test "works for a private user themselves" do
    end

    @tag :skip
    test "works for an instance admin with a private user" do
    end
  end

  describe "resource.collection" do

    test "works for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()} collection { #{collection_basics()} }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(%{query: q})
      res2 = assert_resource(res, res2)
      assert %{"collection" => coll2} = res2
      assert_collection(coll, coll2)
    end

    test "works for an instance admin" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()} collection { #{collection_basics()} }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(conn, %{query: q})
      res2 = assert_resource(res, res2)
      assert %{"collection" => coll2} = res2
      assert_collection(coll, coll2)
    end

    test "works for a user with a public user" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()} collection { #{collection_basics()} }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(conn, %{query: q})
      res2 = assert_resource(res, res2)
      assert %{"collection" => coll2} = res2
      assert_collection(coll, coll2)
    end

    @tag :skip
    test "does not work for a guest with a private user" do
    end

    @tag :skip
    test "works with a user for a private user they follow" do
    end

    @tag :skip
    test "works for a private user themselves" do
    end

    @tag :skip
    test "works for an instance admin with a private user" do
    end
  end

  describe "resource.likes" do

    test "works for a guest with a public user" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      {:ok, alice_like} = Likes.create(alice, res, %{is_local: true})
      {:ok, bob_like} = Likes.create(bob, res, %{is_local: true})
      {:ok, eve_like} = Likes.create(eve, res, %{is_local: true})
      likes = [eve_like, bob_like, alice_like]
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()}
          likes {
            #{page_basics()}
            edges {
              #{like_basics()}
              context { ... on Resource { #{resource_basics()} } }
              creator { #{user_basics()} }
            }
          }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(%{query: q})
      res2 = assert_resource(res, res2)
      assert %{"likes" => likes2} = res2
      edges = assert_edges_page(likes2).edges
      assert Enum.count(edges) == Enum.count(likes)
      for {like, edge} <- Enum.zip(likes, edges) do
        assert_like(like, edge)
      end
    end

    test "works for a user with a public user" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      {:ok, alice_like} = Likes.create(alice, res, %{is_local: true})
      {:ok, bob_like} = Likes.create(bob, res, %{is_local: true})
      {:ok, eve_like} = Likes.create(eve, res, %{is_local: true})
      likes = [eve_like, bob_like, alice_like]
      mallory = fake_user!()
      conn = user_conn(mallory)
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()}
          likes {
            #{page_basics()}
            edges {
              #{like_basics()}
              context { ... on Resource { #{resource_basics()} } }
              creator { #{user_basics()} }
            }
          }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(conn, %{query: q})
      res2 = assert_resource(res, res2)
      assert %{"likes" => likes2} = res2
      edges = assert_edges_page(likes2).edges
      assert Enum.count(edges) == Enum.count(likes)
      for {like, edge} <- Enum.zip(likes, edges) do
        assert_like(like, edge)
      end
    end

    test "works for an instance admin with a public user" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      {:ok, alice_like} = Likes.create(alice, res, %{is_local: true})
      {:ok, bob_like} = Likes.create(bob, res, %{is_local: true})
      {:ok, eve_like} = Likes.create(eve, res, %{is_local: true})
      likes = [eve_like, bob_like, alice_like]
      mallory = fake_user!(%{is_instance_admin: true})
      conn = user_conn(mallory)
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()}
          likes {
            #{page_basics()}
            edges {
              #{like_basics()}
              context { ... on Resource { #{resource_basics()} } }
              creator { #{user_basics()} }
            }
          }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(conn, %{query: q})
      res2 = assert_resource(res, res2)
      assert %{"likes" => likes2} = res2
      edges = assert_edges_page(likes2).edges
      assert Enum.count(edges) == Enum.count(likes)
      for {like, edge} <- Enum.zip(likes, edges) do
        assert_like(like, edge)
      end
    end

  end

  describe "resource.flags" do

    test "empty for a guest with a public resource" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      {:ok, alice_flag} = Flags.create(alice, res, %{is_local: true, message: "naughty"})
      {:ok, bob_flag} = Flags.create(bob, res, %{is_local: true, message: "naughty"})
      {:ok, eve_flag} = Flags.create(eve, res, %{is_local: true, message: "naughty"})
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()}
          flags {
            #{page_basics()}
            edges {
              #{flag_basics()}
              context { ... on Resource { #{resource_basics()} } }
              creator { #{user_basics()} }
            }
          }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(%{query: q})
      res2 = assert_resource(res, res2)
      assert %{"flags" => flags2} = res2
      assert [] == assert_edges_page(flags2).edges
    end

    test "empty for a user with a public resource" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      {:ok, alice_flag} = Flags.create(alice, res, %{is_local: true, message: "naughty"})
      {:ok, bob_flag} = Flags.create(bob, res, %{is_local: true, message: "naughty"})
      {:ok, eve_flag} = Flags.create(eve, res, %{is_local: true, message: "naughty"})
      mallory = fake_user!()
      conn = user_conn(mallory)
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()}
          flags {
            #{page_basics()}
            edges {
              #{flag_basics()}
              context { ... on Resource { #{resource_basics()} } }
              creator { #{user_basics()} }
            }
          }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(conn, %{query: q})
      res2 = assert_resource(res, res2)
      assert %{"flags" => flags2} = res2
      assert [] == assert_edges_page(flags2).edges
    end

    test "works for a user who has flagged a public resource" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      {:ok, alice_flag} = Flags.create(alice, res, %{is_local: true, message: "naughty"})
      {:ok, bob_flag} = Flags.create(bob, res, %{is_local: true, message: "naughty"})
      {:ok, eve_flag} = Flags.create(eve, res, %{is_local: true, message: "naughty"})
      flags = [eve_flag]
      conn = user_conn(eve)
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()}
          flags {
            #{page_basics()}
            edges {
              #{flag_basics()}
              context { ... on Resource { #{resource_basics()} } }
              creator { #{user_basics()} }
            }
          }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(conn, %{query: q})
      res2 = assert_resource(res, res2)
      assert %{"flags" => flags2} = res2
      edges = assert_edges_page(flags2).edges
      assert Enum.count(edges) == Enum.count(flags)
      for {flag, edge} <- Enum.zip(flags, edges) do
        assert_flag(flag, edge)
      end
    end

    test "works for an instance admin with a public user" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = fake_resource!(alice, coll)
      {:ok, alice_flag} = Flags.create(alice, res, %{is_local: true, message: "naughty"})
      {:ok, bob_flag} = Flags.create(bob, res, %{is_local: true, message: "naughty"})
      {:ok, eve_flag} = Flags.create(eve, res, %{is_local: true, message: "naughty"})
      flags = [eve_flag, bob_flag, alice_flag]
      mallory = fake_user!(%{is_instance_admin: true})
      conn = user_conn(mallory)
      q = """
      { resource(resourceId: "#{res.id}") {
          #{resource_basics()}
          flags {
            #{page_basics()}
            edges {
              #{flag_basics()}
              context { ... on Resource { #{resource_basics()} } }
              creator { #{user_basics()} }
            }
          }
        }
      }
      """
      assert %{"resource" => res2} = gql_post_data(conn, %{query: q})
      res2 = assert_resource(res, res2)
      assert %{"flags" => flags2} = res2
      edges = assert_edges_page(flags2).edges
      assert Enum.count(edges) == Enum.count(flags)
      for {flag, edge} <- Enum.zip(flags, edges) do
        assert_flag(flag, edge)
      end
    end

    @tag :skip
    test "works for a community moderator" do
    end
  end

end
