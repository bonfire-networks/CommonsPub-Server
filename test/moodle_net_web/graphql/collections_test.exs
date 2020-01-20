# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CollectionsTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNet.Test.Fake
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import MoodleNet.Test.Faking
  alias MoodleNet.{Flags, Follows, Likes}

  describe "collections" do

    test "works for a guest" do
      alice = fake_user!()
      comm_1 = fake_community!(alice)
      coll_1 = fake_collection!(alice, comm_1)
      coll_2 = fake_collection!(alice, comm_1)
      bob = fake_user!()
      comm_2 = fake_community!(bob)
      coll_3 = fake_collection!(bob, comm_2)
      coll_4 = fake_collection!(bob, comm_2)
      coll_5 = fake_collection!(bob, comm_2)
      q = """
      { collections {
          #{page_basics()}
          nodes { #{collection_basics()} }
        }
      }
      """
      assert %{"collections" => colls} = gql_post_data(%{query: q})
      node_list = assert_node_list(colls)
      assert Enum.count(node_list.nodes) == 5
      for node <- node_list.nodes do
        assert_collection(node)
      end
    end

  end
  describe "collection" do

    test "works for the owner" do
      user = fake_user!()
      comm = fake_community!(user)
      coll = fake_collection!(user, comm)
      conn = user_conn(user)
      q = """
      { collection(collectionId: "#{coll.id}") { #{collection_basics()} } }
      """
      query = %{query: q}
      assert %{"collection" => coll2} = gql_post_data(conn, query)
      assert_collection(coll, coll2)
    end

    test "works for a random" do
      user = fake_user!()
      comm = fake_community!(user)
      coll = fake_collection!(user, comm)
      user2 = fake_user!()
      conn = user_conn(user2)
      q = """
      { collection(collectionId: "#{coll.id}") { #{collection_basics()} } }
      """
      query = %{query: q}
      assert %{"collection" => coll2} = gql_post_data(query)
      assert_collection(coll, coll2)
    end

    test "works for a guest" do
      user = fake_user!()
      comm = fake_community!(user)
      coll = fake_collection!(user, comm)
      q = """
      { collection(collectionId: "#{coll.id}") { #{collection_basics()} } }
      """
      query = %{query: q}
      assert %{"collection" => coll2} = gql_post_data(query)
      assert_collection(coll, coll2)
    end
  end

  describe "createCollection" do

    test "works for a user" do
      alice = fake_user!()
      bob = fake_user!()
      conn = user_conn(alice)
      comm = fake_community!(bob)
      ci = Fake.collection_input()
      q = """
      mutation Test($collection: CollectionInput!) {
        createCollection(communityId: "#{comm.id}", collection: $collection) {
          #{collection_basics()}
        }
      }
      """
      vars = %{"collection" => ci}
      query = %{query: q, operation: "Test", variables: vars}
      assert %{"createCollection" => coll} = gql_post_data(conn, query)
      coll = assert_collection(coll)
      assert coll.name == ci["name"]
      assert coll.summary == ci["summary"]
      assert coll.icon == ci["icon"]
    end

    test "does not work for a guest" do
      bob = fake_user!()
      comm = fake_community!(bob)
      ci = Fake.collection_input()
      q = """
      mutation Test($collection: CollectionInput!) {
        createCollection(communityId: "#{comm.id}", collection: $collection) {
          #{collection_basics()}
        }
      }
      """
      vars = %{"collection" => ci}
      query = %{query: q, operation: "Test", variables: vars}
      assert err = gql_post_errors(query)
    end

  end
  describe "updateCollection" do
    test "works for the collection owner" do
      alice = fake_user!()
      bob = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      conn = user_conn(bob)
      ci = Fake.collection_input()
      q = """
      mutation Test($collection: CollectionInput!) {
        updateCollection(collectionId: "#{coll.id}", collection: $collection) {
          #{collection_basics()}
        }
      }
      """
      vars = %{"collection" => ci}
      query = %{query: q, operation: "Test", variables: vars}
      assert %{"updateCollection" => coll2} = gql_post_data(conn, query)
      coll2 = assert_collection(coll2)
      assert coll2.name == ci["name"]
      assert coll2.summary == ci["summary"]
      assert coll2.icon == ci["icon"]
      # assert err = gql_post_errors(query)
    end
    test "works for the community owner" do
      alice = fake_user!()
      bob = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      conn = user_conn(alice)
      ci = Fake.collection_input()
      q = """
      mutation Test($collection: CollectionInput!) {
        updateCollection(collectionId: "#{coll.id}", collection: $collection) {
          #{collection_basics()}
        }
      }
      """
      vars = %{"collection" => ci}
      query = %{query: q, operation: "Test", variables: vars}
      assert %{"updateCollection" => coll2} = gql_post_data(conn, query)
      coll2 = assert_collection(coll2)
      assert coll2.name == ci["name"]
      assert coll2.summary == ci["summary"]
      assert coll2.icon == ci["icon"]
      # assert err = gql_post_errors(query)
    end
    test "works for an instance admin" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!(%{is_instance_admin: true})
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      conn = user_conn(eve)
      ci = Fake.collection_input()
      q = """
      mutation Test($collection: CollectionInput!) {
        updateCollection(collectionId: "#{coll.id}", collection: $collection) {
          #{collection_basics()}
        }
      }
      """
      vars = %{"collection" => ci}
      query = %{query: q, operation: "Test", variables: vars}
      assert %{"updateCollection" => coll2} = gql_post_data(conn, query)
      coll2 = assert_collection(coll2)
      assert coll2.name == ci["name"]
      assert coll2.summary == ci["summary"]
      assert coll2.icon == ci["icon"]
      # assert err = gql_post_errors(query)
    end
    test "does not work for a random" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      conn = user_conn(eve)
      ci = Fake.collection_input()
      q = """
      mutation Test($collection: CollectionInput!) {
        updateCollection(collectionId: "#{coll.id}", collection: $collection) {
          #{collection_basics()}
        }
      }
      """
      vars = %{"collection" => ci}
      query = %{query: q, operation: "Test", variables: vars}
      assert err = gql_post_errors(conn, query)
    end
    test "does not work for a guest" do
      alice = fake_user!()
      bob = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(bob, comm)
      ci = Fake.collection_input()
      q = """
      mutation Test($collection: CollectionInput!) {
        updateCollection(collectionId: "#{coll.id}", collection: $collection) {
          #{collection_basics()}
        }
      }
      """
      vars = %{"collection" => ci}
      query = %{query: q, operation: "Test", variables: vars}
      assert err = gql_post_errors(query)
    end
  end

  describe "delete (via common)" do
    @tag :skip
    test "works for creator" do
    end
    @tag :skip
    test "works for community owner" do
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

  describe "collection.lastActivity" do
    @tag :skip
    test "placeholder" do
    end
  end

  describe "collection.myLike" do

    test "is nil for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} myLike { #{like_basics()} }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(%{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"myLike" => nil} = coll2
    end

    test "is nil for a user who doesn't like" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      bob = fake_user!()
      conn = user_conn(bob)
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} myLike { #{like_basics()} }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(conn, %{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"myLike" => nil} = coll2
    end

    test "is nil for an instance admin who doesn't like" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} myLike { #{like_basics()} }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(conn, %{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"myLike" => nil} = coll2
    end

    test "works for a user who liked" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      bob = fake_user!()
      conn = user_conn(bob)
      {:ok, like} = Likes.create(bob, coll, %{is_local: true})
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} myLike { #{like_basics()} }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(conn, %{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"myLike" => like2} = coll2
      assert_like(like, like2)
    end

    test "works for an instance admin who likes" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      {:ok, like} = Likes.create(bob, coll, %{is_local: true})
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} myLike { #{like_basics()} }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(conn, %{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"myLike" => like2} = coll2
    end

  end

  describe "collection.myFollow" do

    test "is nil for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} myFollow { #{follow_basics()} }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(%{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"myFollow" => nil} = coll2
    end

    test "is nil for a user who doesn't follow" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      bob = fake_user!()
      conn = user_conn(bob)
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} myFollow { #{follow_basics()} }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(conn, %{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"myFollow" => nil} = coll2
    end

    test "is nil for an instance admin who doesn't follow" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} myFollow { #{follow_basics()} }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(conn, %{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"myFollow" => nil} = coll2
    end

    test "works for a user who follows" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      bob = fake_user!()
      conn = user_conn(bob)
      {:ok, follow} = Follows.create(bob, coll, %{is_local: true})
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} myFollow { #{follow_basics()} }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(conn, %{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"myFollow" => follow2} = coll2
      assert_follow(follow, follow2)
    end

    test "works for an instance admin who follows" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      {:ok, follow} = Follows.create(bob, coll, %{is_local: true})
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} myFollow { #{follow_basics()} }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(conn, %{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"myFollow" => follow2} = coll2
      assert_follow(follow, follow2)
    end

  end

  describe "collection.myFlag" do

    test "is nil for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} myFlag { #{flag_basics()} }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(%{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"myFlag" => nil} = coll2
    end

    test "is nil for a user who doesn't flag" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      bob = fake_user!()
      conn = user_conn(bob)
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} myFlag { #{flag_basics()} }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(conn, %{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"myFlag" => nil} = coll2
    end

    test "is nil for an instance admin who doesn't flag" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} myFlag { #{flag_basics()} }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(conn, %{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"myFlag" => nil} = coll2
    end

    test "works for a user who flags" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      bob = fake_user!()
      conn = user_conn(bob)
      {:ok, flag} = Flags.create(bob, coll, %{is_local: true, message: "naughty"})
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} myFlag { #{flag_basics()} }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(conn, %{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"myFlag" => flag2} = coll2
      assert_flag(flag, flag2)
    end

    test "works for an instance admin who flags" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      {:ok, flag} = Flags.create(bob, coll, %{is_local: true, message: "naughty"})
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} myFlag { #{flag_basics()} }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(conn, %{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"myFlag" => flag2} = coll2
      assert_flag(flag, flag2)
    end

  end

  describe "collection.creator" do

    test "placeholder" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} creator { #{user_basics()} }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(%{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"creator" => user} = coll2
      assert_user(alice, user)
    end
  end
  describe "collection.community" do

    test "works" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} community { #{community_basics()} }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(%{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"community" => comm2} = coll2
      assert_community(comm, comm2)
    end

  end

  describe "collection.resources" do

    test "works for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = Enum.map(1..5, fn _ -> fake_resource!(alice, coll) end)
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} resources {
            #{page_basics()}
            edges { cursor node { #{resource_basics()} } }
          }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(%{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"resources" => res} = coll2
      edge_list = assert_edge_list(res, &(&1.id))
      assert Enum.count(edge_list.edges) == 5
      for edge <- edge_list.edges do
        res = assert_resource(edge.node)
        assert assert res.id == edge.cursor
      end
    end

    test "works for an instance admin" do
      alice = fake_user!(%{is_instance_admin: true})
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = Enum.map(1..5, fn _ -> fake_resource!(alice, coll) end)
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} resources {
            #{page_basics()}
            edges { cursor node { #{resource_basics()} } }
          }
        }
      }
      """
      conn = user_conn(alice)
      assert %{"collection" => coll2} = gql_post_data(conn, %{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"resources" => res} = coll2
      edge_list = assert_edge_list(res, &(&1.id))
      assert Enum.count(edge_list.edges) == 5
      for edge <- edge_list.edges do
        res = assert_resource(edge.node)
        assert assert res.id == edge.cursor
      end
    end

    test "works for a user for a public collection" do
      alice = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      res = Enum.map(1..5, fn _ -> fake_resource!(alice, coll) end)
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()} resources {
            #{page_basics()}
            edges { cursor node { #{resource_basics()} } }
          }
        }
      }
      """
      conn = user_conn(alice)
      assert %{"collection" => coll2} = gql_post_data(conn, %{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"resources" => res} = coll2
      edge_list = assert_edge_list(res, &(&1.id))
      assert Enum.count(edge_list.edges) == 5
      for edge <- edge_list.edges do
        res = assert_resource(edge.node)
        assert assert res.id == edge.cursor
      end
    end

  end

  describe "collection.followers" do

    test "works for a guest" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      {:ok, bob_follow} = Follows.create(bob, coll, %{is_local: true})
      {:ok, eve_follow} = Follows.create(eve, coll, %{is_local: true})
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()}
          followers {
            #{page_basics()}
            edges {
              cursor
              node {
                #{follow_basics()}
                creator { #{user_basics()} }
              }
            }
          }
        }
      }
      """
      assert %{"collection" => coll} = gql_post_data(%{query: q})
      coll = assert_collection(coll)
      assert %{"followers" => folls2} = coll
      edges = assert_edge_list(folls2, &(&1.id)).edges
      assert Enum.count(edges) == 3
      for edge <- edges do
        foll = assert_follow(edge.node)
        assert foll.id == edge.cursor
      end
    end

    test "works for a user" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      mallory = fake_user!()
      conn = user_conn(mallory)
      {:ok, bob_follow} = Follows.create(bob, coll, %{is_local: true})
      {:ok, eve_follow} = Follows.create(eve, coll, %{is_local: true})
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()}
          followers {
            #{page_basics()}
            edges {
              cursor
              node {
                #{follow_basics()}
                creator { #{user_basics()} }
              }
            }
          }
        }
      }
      """
      assert %{"collection" => coll} = gql_post_data(conn, %{query: q})
      coll = assert_collection(coll)
      assert %{"followers" => folls2} = coll
      edges = assert_edge_list(folls2, &(&1.id)).edges
      assert Enum.count(edges) == 3
      for edge <- edges do
        foll = assert_follow(edge.node)
        assert foll.id == edge.cursor
      end
    end

    test "works for an instance admin" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      mallory = fake_user!(%{is_instance_admin: true})
      conn = user_conn(mallory)
      {:ok, bob_follow} = Follows.create(bob, coll, %{is_local: true})
      {:ok, eve_follow} = Follows.create(eve, coll, %{is_local: true})
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()}
          followers {
            #{page_basics()}
            edges {
              cursor
              node {
                #{follow_basics()}
                creator { #{user_basics()} }
              }
            }
          }
        }
      }
      """
      assert %{"collection" => coll} = gql_post_data(conn, %{query: q})
      coll = assert_collection(coll)
      assert %{"followers" => folls2} = coll
      edges = assert_edge_list(folls2, &(&1.id)).edges
      assert Enum.count(edges) == 3
      for edge <- edges do
        foll = assert_follow(edge.node)
        assert foll.id == edge.cursor
      end
    end
  end

  describe "collection.likes" do

    test "works for a guest with a public user" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      {:ok, alice_like} = Likes.create(alice, coll, %{is_local: true})
      {:ok, bob_like} = Likes.create(bob, coll, %{is_local: true})
      {:ok, eve_like} = Likes.create(eve, coll, %{is_local: true})
      likes = [eve_like, bob_like, alice_like]
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()}
          likes {
            #{page_basics()}
            edges {
              cursor
              node {
                #{like_basics()}
                context { ... on Collection { #{collection_basics()} } }
                creator { #{user_basics()} }
              }
            }
          }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(%{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"likes" => likes2} = coll2
      edges = assert_edge_list(likes2, &(&1.id)).edges
      assert Enum.count(edges) == Enum.count(likes)
      for {like, edge} <- Enum.zip(likes, edges) do
        assert_like(like, edge.node)
      end
    end

    test "works for a user with a public user" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      {:ok, alice_like} = Likes.create(alice, coll, %{is_local: true})
      {:ok, bob_like} = Likes.create(bob, coll, %{is_local: true})
      {:ok, eve_like} = Likes.create(eve, coll, %{is_local: true})
      likes = [eve_like, bob_like, alice_like]
      mallory = fake_user!()
      conn = user_conn(mallory)
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()}
          likes {
            #{page_basics()}
            edges {
              cursor
              node {
                #{like_basics()}
                context { ... on Collection { #{collection_basics()} } }
                creator { #{user_basics()} }
              }
            }
          }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(conn, %{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"likes" => likes2} = coll2
      edges = assert_edge_list(likes2, &(&1.id)).edges
      assert Enum.count(edges) == Enum.count(likes)
      for {like, edge} <- Enum.zip(likes, edges) do
        assert_like(like, edge.node)
      end
    end

    test "works for an instance admin with a public user" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      {:ok, alice_like} = Likes.create(alice, coll, %{is_local: true})
      {:ok, bob_like} = Likes.create(bob, coll, %{is_local: true})
      {:ok, eve_like} = Likes.create(eve, coll, %{is_local: true})
      likes = [eve_like, bob_like, alice_like]
      mallory = fake_user!(%{is_instance_admin: true})
      conn = user_conn(mallory)
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()}
          likes {
            #{page_basics()}
            edges {
              cursor
              node {
                #{like_basics()}
                context { ... on Collection { #{collection_basics()} } }
                creator { #{user_basics()} }
              }
            }
          }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(conn, %{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"likes" => likes2} = coll2
      edges = assert_edge_list(likes2, &(&1.id)).edges
      assert Enum.count(edges) == Enum.count(likes)
      for {like, edge} <- Enum.zip(likes, edges) do
        assert_like(like, edge.node)
      end
    end

  end

  describe "collection.flags" do

    test "empty for a guest with a public collection" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      {:ok, alice_flag} = Flags.create(alice, coll, %{is_local: true, message: "naughty"})
      {:ok, bob_flag} = Flags.create(bob, coll, %{is_local: true, message: "naughty"})
      {:ok, eve_flag} = Flags.create(eve, coll, %{is_local: true, message: "naughty"})
      flags = [eve_flag, bob_flag, alice_flag]
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()}
          flags {
            #{page_basics()}
            edges {
              cursor
              node {
                #{flag_basics()}
                context { ... on Collection { #{collection_basics()} } }
                creator { #{user_basics()} }
              }
            }
          }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(%{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"flags" => flags2} = coll2
      assert [] == assert_edge_list(flags2, &(&1.id)).edges
    end

    test "empty for a user with a public collection" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      {:ok, alice_flag} = Flags.create(alice, coll, %{is_local: true, message: "naughty"})
      {:ok, bob_flag} = Flags.create(bob, coll, %{is_local: true, message: "naughty"})
      {:ok, eve_flag} = Flags.create(eve, coll, %{is_local: true, message: "naughty"})
      flags = [eve_flag, bob_flag, alice_flag]
      mallory = fake_user!()
      conn = user_conn(mallory)
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()}
          flags {
            #{page_basics()}
            edges {
              cursor
              node {
                #{flag_basics()}
                context { ... on Collection { #{collection_basics()} } }
                creator { #{user_basics()} }
              }
            }
          }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(conn, %{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"flags" => flags2} = coll2
      assert [] == assert_edge_list(flags2, &(&1.id)).edges
    end

    test "works for a user who has flagged a public collection" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      {:ok, alice_flag} = Flags.create(alice, coll, %{is_local: true, message: "naughty"})
      {:ok, bob_flag} = Flags.create(bob, coll, %{is_local: true, message: "naughty"})
      {:ok, eve_flag} = Flags.create(eve, coll, %{is_local: true, message: "naughty"})
      flags = [eve_flag]
      conn = user_conn(eve)
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()}
          flags {
            #{page_basics()}
            edges {
              cursor
              node {
                #{flag_basics()}
                context { ... on Collection { #{collection_basics()} } }
                creator { #{user_basics()} }
              }
            }
          }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(conn, %{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"flags" => flags2} = coll2
      edges = assert_edge_list(flags2, &(&1.id)).edges
      assert Enum.count(edges) == Enum.count(flags)
      for {flag, edge} <- Enum.zip(flags, edges) do
        assert_flag(flag, edge.node)
      end
    end

    test "works for an instance admin with a public user" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      coll = fake_collection!(alice, comm)
      {:ok, alice_flag} = Flags.create(alice, coll, %{is_local: true, message: "naughty"})
      {:ok, bob_flag} = Flags.create(bob, coll, %{is_local: true, message: "naughty"})
      {:ok, eve_flag} = Flags.create(eve, coll, %{is_local: true, message: "naughty"})
      flags = [eve_flag, bob_flag, alice_flag]
      mallory = fake_user!(%{is_instance_admin: true})
      conn = user_conn(mallory)
      q = """
      { collection(collectionId: "#{coll.id}") {
          #{collection_basics()}
          flags {
            #{page_basics()}
            edges {
              cursor
              node {
                #{flag_basics()}
                context { ... on Collection { #{collection_basics()} } }
                creator { #{user_basics()} }
              }
            }
          }
        }
      }
      """
      assert %{"collection" => coll2} = gql_post_data(conn, %{query: q})
      coll2 = assert_collection(coll, coll2)
      assert %{"flags" => flags2} = coll2
      edges = assert_edge_list(flags2, &(&1.id)).edges
      assert Enum.count(edges) == Enum.count(flags)
      for {flag, edge} <- Enum.zip(flags, edges) do
        assert_flag(flag, edge.node)
      end
    end

    @tag :skip
    test "works for a community moderator" do
    end
  end

  describe "collection.threads" do
    @tag :skip
    test "placeholder" do
    end
  end
  describe "collection.outbox" do
    @tag :skip
    test "placeholder" do
    end
  end

  # @list_query """
  # { collections { 
  #     pageInfo { startCursor endCursor }
  #     totalCount
  #     nodes { id } } }
  # """

  # describe "CollectionsResolver.list" do

  #   test "works for a guest" do
  #     alice = fake_user!()
  #     comm_1 = fake_community!(alice)
  #     coll_1 = fake_collection!(alice, comm_1)
  #     coll_2 = fake_collection!(alice, comm_1)
  #     bob = fake_user!()
  #     comm_2 = fake_community!(bob)
  #     coll_3 = fake_collection!(bob, comm_2)
  #     coll_4 = fake_collection!(bob, comm_2)
  #     coll_5 = fake_collection!(bob, comm_2)
  #     eve = fake_user!()
  #     conn = user_conn(eve)
  #     assert ret = Map.fetch!(gql_post_data(conn, %{query: @list_query}), "collections")
  #     assert %{"pageInfo" => info, "nodes" => nodes, "totalCount" => count} = ret
  #     assert is_list(nodes)
  #     assert Enum.count(nodes) == 5
  #     # TODO: test ids
  #   end

  #   test "does not return deleted items" do
  #     alice = fake_user!()
  #     comm_1 = fake_community!(alice)
  #     coll_1 = fake_collection!(alice, comm_1)
  #     coll_2 = fake_collection!(alice, comm_1)
  #     assert {:ok, _} = Collections.soft_delete(coll_1)
  #     eve = fake_user!()
  #     conn = user_conn(eve)
  #     assert ret = Map.fetch!(gql_post_data(conn, %{query: @list_query}), "collections")
  #     assert %{"pageInfo" => info, "nodes" => nodes, "totalCount" => count} = ret
  #     assert is_list(nodes)
  #     assert Enum.count(nodes) == 1
  #   end

  #   test "does not return items from a deleted community" do
  #     alice = fake_user!()
  #     comm_1 = fake_community!(alice)
  #     coll_1 = fake_collection!(alice, comm_1)
  #     comm_2 = fake_community!(alice)
  #     coll_2 = fake_collection!(alice, comm_2)
  #     assert {:ok, _} = Communities.soft_delete(comm_1)
  #     eve = fake_user!()
  #     conn = user_conn(eve)
  #     assert ret = Map.fetch!(gql_post_data(conn, %{query: @list_query}), "collections")
  #     assert %{"pageInfo" => info, "nodes" => nodes, "totalCount" => count} = ret
  #     assert is_list(nodes)
  #     assert Enum.count(nodes) == 1
  #   end

  #   # @tag :skip
  #   # @for_moot false
  #   # test "does not return private items" do
  #   # end

  # end

  # describe "CollectionsResolver.fetch" do

  #   setup do
  #     alice = fake_user!()
  #     community = fake_community!(alice)
  #     collection = fake_collection!(alice, community)
  #     {:ok, %{alice: alice, community: community, collection: collection}}
  #   end

  #   test "works for a guest", ctx do
      
  #     query = """
  #     { collection(collectionId: "#{ctx.collection.id}") {
  #         id name content summary icon primaryLanguage { id englishName }
  #       } }
  #     """
  #     assert %{"collection" => ret} = gql_post_data(json_conn(), %{query: query})
  #     assert_collection_eq(ctx.collection, ret)
  #   end

  #   test "works for a user", ctx do
  #     bob = fake_user!()
  #     query = """
  #     { collection(collectionId: "#{ctx.collection.id}") {
  #         id name content summary icon primaryLanguage { id englishName }
  #       } }
  #     """
  #     assert %{"collection" => ret} = gql_post_data(json_conn(), %{query: query})
  #     assert_collection_eq(ctx.collection, ret)
  #   end

  #   test "works for the collection creator", ctx do
      
  #     query = """
  #     { collection(collectionId: "#{ctx.collection.id}") {
  #         id name content summary icon primaryLanguage { id englishName }
  #       } }
  #     """
  #     assert %{"collection" => ret} = gql_post_data(json_conn(), %{query: query})
  #     assert_collection_eq(ctx.collection, ret)
  #   end
  # end

  # describe "CollectionsResolver.create" do

  #   # setup do
  #   #   alice = fake_user!()
  #   #   community = fake_community!(alice)
  #   #   input = Fake.collection()
  #   #   query = """
  #   #   mutation {
  #   #     createCollection(communityId: "#{}", collection: $collection) {
  #   #       id name content summary icon primaryLanguage { id englishName }
  #   #     }
  #   #   }
  #   #   """
  #   #   {:ok, %{alice: alice, community: community, input: input, query: query}}
  #   # end

  #   # test "does not work for a guest", ctx do
      
  #   # end
  #   # test "works for an instance admin", ctx do

  #   # end
  #   # test "works for the community owner", ctx do

  #   # end
  #   # test "works for a community follower", ctx do

  #   # end
  #   # test "does not work for a randomer", ctx do
  #   # end
  #   # test "works for the community owner", ctx do

  #   # end

  # end

  # describe "CollectionsResolver.update" do
    
  # end

  # describe "CollectionsResolver.delete" do
  #   setup do
  #     alice = fake_user!()
  #     bob = fake_user!()
  #     community = fake_community!(alice)
  #     collection = fake_collection!(bob, community)
  #     query = """
  #     mutation { deleteCollection(collectionId: "#{collection.id}") }
  #     """
  #     {:ok, %{alice: alice, bob: bob, community: community, collection: collection, query: query}}
  #   end
  #   test "does not work for a guest", ctx do
  #     assert errs = gql_post_errors(json_conn(), %{query: ctx.query})
  #     assert_not_logged_in(errs, ["deleteCollection"])
  #   end

  #   test "does not work for a regular user", ctx do
  #     eve = fake_user!()
  #     conn = user_conn(eve)
  #     assert errs = gql_post_errors(conn, %{query: ctx.query})
  #     assert_not_permitted(errs, ["deleteCollection"])
  #   end

  #   test "works for the collection creator", ctx do
  #     conn = user_conn(ctx.bob)
  #     assert %{"deleteCollection" => true} = gql_post_data(conn, %{query: ctx.query})
  #   end

  #   test "works for the community owner", ctx do
  #     conn = user_conn(ctx.alice)
  #     assert %{"deleteCollection" => true} = gql_post_data(conn, %{query: ctx.query})
  #   end

  #   test "works for an instance admin", ctx do
  #     eve = fake_user!()
  #     assert {:ok, eve} = Users.make_instance_admin(eve)
  #     conn = user_conn(eve)
  #     assert %{"deleteCollection" => true} = gql_post_data(conn, %{query: ctx.query})
  #   end

  # end

end
