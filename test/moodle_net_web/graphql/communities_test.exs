# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommunityTest do
  use MoodleNetWeb.ConnCase, async: true
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import MoodleNet.Test.Faking
  import MoodleNetWeb.Test.ConnHelpers
  alias MoodleNet.Test.Fake
  alias MoodleNet.{Flags, Follows, Likes}

  describe "communities" do
    test "works" do
      alice = fake_user!()
      bob = fake_user!()
      comm_1 = fake_community!(alice)
      comm_2 = fake_community!(alice)
      comm_3 = fake_community!(bob)
      comm_4 = fake_community!(bob)
      comm_5 = fake_community!(bob)
      comms = [comm_1, comm_2, comm_3, comm_4, comm_5]
      keyed = Enum.reduce(comms, %{}, fn comm, acc ->
        Map.put(acc, comm.id, comm)
      end)
      q = """
      { communities {
          #{page_basics()}
          nodes { #{community_basics()} }
        }
      }
      """
      assert %{"communities" => comms2} = gql_post_data(%{query: q})
      node_list = assert_node_list(comms2)
      assert Enum.count(node_list.nodes) == 5
      for node <- node_list.nodes do
        comm = assert_community(keyed[node["id"]], node)
        assert comm.collection_count == 0
        assert comm.follower_count == 1
        assert comm.liker_count == 0
      end
    end
  end

  describe "communities.creator" do
    test "works" do
      alice = fake_user!()
      bob = fake_user!()
      comm_1 = fake_community!(alice)
      comm_2 = fake_community!(alice)
      comm_3 = fake_community!(bob)
      comm_4 = fake_community!(bob)
      comm_5 = fake_community!(bob)
      comms = [comm_1, comm_2, comm_3, comm_4, comm_5]
      keyed = Enum.reduce(comms, %{}, fn comm, acc ->
        Map.put(acc, comm.id, comm)
      end)
      named = Enum.reduce([alice, bob], %{}, fn person, acc ->
        Map.put(acc, person.id, person)
      end)
      q = """
      { communities {
          #{page_basics()}
          nodes {
            #{community_basics()}
            creator { #{user_basics()} }
          }
        }
      }
      """
      assert %{"communities" => comms2} = gql_post_data(%{query: q})
      node_list = assert_node_list(comms2)
      assert Enum.count(node_list.nodes) == 5
      for node <- node_list.nodes do
        comm = assert_community(keyed[node["id"]], node)
        assert %{"creator" => creator} = comm
        assert_user(named[creator["id"]], creator)
      end
    end
  end

  describe "community" do

    test "works for guest for a public community" do
      user = fake_user!()
      comm = fake_community!(user)
      q = """
      { community(communityId: "#{comm.id}") { #{community_basics()} } }
      """
      query = %{query: q}
      assert %{"community" => comm2} = gql_post_data(query)
      comm2 = assert_community(comm, comm2)
      assert comm2.follower_count == 1
      assert comm2.liker_count == 0
      # assert comm2collectionsCount"] == 0
    end

    # test "does not work for a guest in a private community" do
    # end

    test "works for a random user for a public community" do
      user = fake_user!()
      user2 = fake_user!()
      conn = user_conn(user2)
      comm = fake_community!(user)
      q = """
      { community(communityId: "#{comm.id}") { #{community_basics()} } }
      """
      query = %{query: q}
      assert %{"community" => comm2} = gql_post_data(conn, query)
      assert_community(comm, comm2)
    end
    
    test "does not work for a random user for a private community" do
    end

    test "works for a follower in a private community" do
      user = fake_user!()
      conn = user_conn(user)
      comm = fake_community!(user)
      q = """
      { community(communityId: "#{comm.id}") { #{community_basics()} } }
      """
      query = %{query: q}
      assert %{"community" => comm2} = gql_post_data(conn, query)
      assert_community(comm, comm2)
    end

    test "works for an instance admin in a public community" do
      user = fake_user!(%{is_instance_admin: true})
      conn = user_conn(user)
      comm = fake_community!(user)
      q = """
      { community(communityId: "#{comm.id}") { #{community_basics()} } }
      """
      query = %{query: q}
      assert %{"community" => comm2} = gql_post_data(conn, query)
      assert_community(comm, comm2)
    end

    test "works for an instance admin in a private community" do
    end

    test "doesn't work for nonexistent" do
    end

  end

  describe "createCommunity" do
    test "works for a user" do
      user = fake_user!()
      conn = user_conn(user)
      ci = Fake.community_create_input()
      vars = %{"community" => ci}
      q = """
      mutation Test($community: CommunityInput!) {
        createCommunity(community: $community) {
          #{community_basics()}
        }
      }
      """
      query = %{query: q, mutation: "Test", variables: vars}
      assert %{"createCommunity" => comm2} = gql_post_data(conn, query)
      comm2 = assert_community(comm2)
      assert ci["preferredUsername"] == comm2.preferred_username
      assert ci["name"] == comm2.name
      assert ci["summary"] == comm2.summary
      assert ci["icon"] == comm2.icon
      assert ci["image"] == comm2.image
    end

    test "does not work for a guest" do
      vars = %{"community" => Fake.community_create_input()}
      q = """
      mutation Test($community: CommunityInput!) {
        createCommunity(community: $community) {
          #{community_basics()}
        }
      }
      """
      query = %{query: q, mutation: "Test", variables: vars}
      assert err = gql_post_errors(query)
    end
  end

  describe "updateCommunity" do

    test "works for the community creator" do
      user = fake_user!()
      conn = user_conn(user)
      comm = fake_community!(user)
      ci = Fake.community_update_input()
      vars = %{"community" => ci, "id" => comm.id}
      q = """
      mutation Test($id: String, $community: CommunityInput!) {
        updateCommunity(communityId: $id, community: $community) {
          #{community_basics()}
        }
      }
      """
      query = %{query: q, mutation: "Test", variables: vars}
      assert %{"updateCommunity" => comm2} = gql_post_data(conn, query)
      comm2 = assert_community(comm2)
      assert ci["name"] == comm2.name
      assert ci["summary"] == comm2.summary
      assert ci["icon"] == comm2.icon
      assert ci["image"] == comm2.image
    end

    test "works for an instance admin" do
      user = fake_user!()
      user2 = fake_user!(%{is_instance_admin: true})
      conn = user_conn(user2)
      comm = fake_community!(user)
      ci = Fake.community_update_input()
      vars = %{"community" => ci, "id" => comm.id}
      q = """
      mutation Test($id: String, $community: CommunityInput!) {
        updateCommunity(communityId: $id, community: $community) {
          #{community_basics()}
        }
      }
      """
      query = %{query: q, mutation: "Test", variables: vars}
      assert %{"updateCommunity" => comm2} = gql_post_data(conn, query)
      comm2 = assert_community(comm2)
      assert ci["name"] == comm2.name
      assert ci["summary"] == comm2.summary
      assert ci["icon"] == comm2.icon
      assert ci["image"] == comm2.image
    end

    test "doesn't work for a random" do
      user = fake_user!()
      user2 = fake_user!()
      conn = user_conn(user2)
      comm = fake_community!(user)
      ci = Fake.community_update_input()
      vars = %{"community" => ci, "id" => comm.id}
      q = """
      mutation Test($id: String, $community: CommunityInput!) {
        updateCommunity(communityId: $id, community: $community) {
          #{community_basics()}
        }
      }
      """
      query = %{query: q, mutation: "Test", variables: vars}
      assert err = gql_post_errors(conn, query)
    end

    test "doesn't work for a guest" do
      user = fake_user!()
      comm = fake_community!(user)
      ci = Fake.community_update_input()
      vars = %{"community" => ci, "id" => comm.id}
      q = """
      mutation Test($id: String, $community: CommunityInput!) {
        updateCommunity(communityId: $id, community: $community) {
          #{community_basics()}
        }
      }
      """
      query = %{query: q, mutation: "Test", variables: vars}
      assert err = gql_post_errors(query)
    end

  end

  describe "delete (via common)" do
    @tag :skip
    test "works for creator" do
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

  describe "community.lastActivity" do
    test "works" do
      
    end
  end

  describe "community.myLike" do

    test "is nil for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()} myLike { #{like_basics()} }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(%{query: q})
      comm2 = assert_community(comm, comm2)
      assert %{"myLike" => nil} = comm2
    end

    test "is nil for an instance admin who does not like it" do
      alice = fake_user!()
      comm = fake_community!(alice)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()} myLike { #{like_basics()} }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(conn, %{query: q})
      comm2 = assert_community(comm, comm2)
      assert %{"myLike" => nil} = comm2
    end

    test "is nil for a user who does not like it" do
      alice = fake_user!()
      comm = fake_community!(alice)
      bob = fake_user!()
      conn = user_conn(bob)
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()} myLike { #{like_basics()} }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(conn, %{query: q})
      comm2 = assert_community(comm, comm2)
      assert %{"myLike" => nil} = comm2
    end

    test "works for an instance admin who likes it" do
      alice = fake_user!()
      comm = fake_community!(alice)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      {:ok, like} = Likes.create(bob, comm, %{is_local: true})
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()} myLike { #{like_basics()} }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(conn, %{query: q})
      comm2 = assert_community(comm, comm2)
      assert %{"myLike" => like2} = comm2
      assert_like(like, like2)
    end

    test "works for a user who likes it" do
      alice = fake_user!()
      comm = fake_community!(alice)
      bob = fake_user!()
      conn = user_conn(bob)
      {:ok, like} = Likes.create(bob, comm, %{is_local: true})
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()} myLike { #{like_basics()} }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(conn, %{query: q})
      comm2 = assert_community(comm, comm2)
      assert %{"myLike" => like2} = comm2
      assert_like(like, like2)
    end
  end

  describe "community.myFlag" do

    test "is nil for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()} myFlag { #{flag_basics()} }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(%{query: q})
      comm2 = assert_community(comm, comm2)
      assert %{"myFlag" => nil} = comm2
    end

    test "is nil for an instance admin who does not flag it" do
      alice = fake_user!()
      comm = fake_community!(alice)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()} myFlag { #{flag_basics()} }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(conn, %{query: q})
      comm2 = assert_community(comm, comm2)
      assert %{"myFlag" => nil} = comm2
    end

    test "is nil for a user who does not flag it" do
      alice = fake_user!()
      comm = fake_community!(alice)
      bob = fake_user!()
      conn = user_conn(bob)
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()} myFlag { #{flag_basics()} }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(conn, %{query: q})
      comm2 = assert_community(comm, comm2)
      assert %{"myFlag" => nil} = comm2
    end

    test "works for an instance admin who flags it" do
      alice = fake_user!()
      comm = fake_community!(alice)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      {:ok, flag} = Flags.create(bob, comm, %{is_local: true, message: "naughty"})
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()} myFlag { #{flag_basics()} }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(conn, %{query: q})
      comm2 = assert_community(comm, comm2)
      assert %{"myFlag" => flag2} = comm2
      assert_flag(flag, flag2)
    end

    test "works for a user who flags it" do
      alice = fake_user!()
      comm = fake_community!(alice)
      bob = fake_user!()
      conn = user_conn(bob)
      {:ok, flag} = Flags.create(bob, comm, %{is_local: true, message: "naughty"})
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()} myFlag { #{flag_basics()} }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(conn, %{query: q})
      comm2 = assert_community(comm, comm2)
      assert %{"myFlag" => flag2} = comm2
      assert_flag(flag, flag2)
    end

  end

  describe "community.myFollow" do

    test "is nil for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()} myFollow { #{follow_basics()} }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(%{query: q})
      comm2 = assert_community(comm, comm2)
      assert %{"myFollow" => nil} = comm2
    end

    test "is nil for a user who doesn't follow" do
      alice = fake_user!()
      comm = fake_community!(alice)
      bob = fake_user!()
      conn = user_conn(bob)
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()} myFollow { #{follow_basics()} }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(conn, %{query: q})
      comm2 = assert_community(comm, comm2)
      assert %{"myFollow" => nil} = comm2
    end

    test "is nil for an instance admin who doesn't follow" do
      alice = fake_user!()
      comm = fake_community!(alice)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()} myFollow { #{follow_basics()} }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(conn, %{query: q})
      comm2 = assert_community(comm, comm2)
      assert %{"myFollow" => nil} = comm2
    end

    test "works for a user who follows" do
      alice = fake_user!()
      comm = fake_community!(alice)
      bob = fake_user!()
      conn = user_conn(bob)
      {:ok, follow} = Follows.create(bob, comm, %{is_local: true})
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()} myFollow { #{follow_basics()} }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(conn, %{query: q})
      comm2 = assert_community(comm, comm2)
      assert %{"myFollow" => follow2} = comm2
      assert_follow(follow, follow2)
    end

    test "works for an instance admin who follows" do
      alice = fake_user!()
      comm = fake_community!(alice)
      bob = fake_user!(%{is_instance_admin: true})
      conn = user_conn(bob)
      {:ok, follow} = Follows.create(bob, comm, %{is_local: true})
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()} myFollow { #{follow_basics()} }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(conn, %{query: q})
      comm2 = assert_community(comm, comm2)
      assert %{"myFollow" => follow2} = comm2
      assert_follow(follow, follow2)
    end

  end

  describe "community.creator" do

    test "works for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()} creator { #{user_basics()} }
        }
      }
      """
      assert %{"community" => comm} = gql_post_data(%{query: q})
      comm = assert_community(comm)
      assert %{"creator" => user} = comm
      assert_user(alice, user)
    end

  end

  describe "community.collections" do
    test "works for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      _colls = Enum.map(1..5, fn _ -> fake_collection!(alice, comm) end)
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()}
          collections {
            pageInfo { startCursor endCursor }
            totalCount
            edges { cursor node { #{collection_basics()} } }
          }
        }
      }
      """
      assert %{"community" => comm} = gql_post_data(%{query: q})
      comm = assert_community(comm)
      assert %{"collections" => colls} = comm
      edge_list = assert_edge_list(colls)
      assert Enum.count(edge_list.edges) == 5
      for edge <- edge_list.edges do
        coll = assert_collection(edge.node)
        assert coll.id == edge.cursor
      end
    end
  end

  describe "community.threads" do

    test "works for a guest when there are no threads" do
      alice = fake_user!()
      comm = fake_community!(alice)
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()}
          threads {
            pageInfo { startCursor endCursor }
            totalCount
            edges {
              cursor
              node {
                #{thread_basics()}
                comments {
                  pageInfo { startCursor endCursor }
                  totalCount
                  edges {
                    cursor
                    node {
                      #{comment_basics()}
                      inReplyTo { #{comment_basics()} }
                    }
                  }
                }
              }
            }
          }
        }
      }
      """
      assert %{"community" => comm} = gql_post_data(%{query: q})
      comm = assert_community(comm)
      assert %{"threads" => threads} = comm
      edge_list = assert_edge_list(threads)
      assert Enum.count(edge_list.edges) == 0
      assert threads["totalCount"] == 0
      # for edge <- edge_list.edges do
      #   coll = assert_collection(edge.node)
      #   assert coll.id == edge.cursor
      # end
    end

    test "works for a guest when there are threads" do
      alice = fake_user!()
      bob = fake_user!()
      comm = fake_community!(alice)
      t1 = fake_thread!(bob, comm)
      t1c1 = fake_comment!(bob, t1)
      t1c2 = fake_comment!(alice, t1)
      t2 = fake_thread!(alice, comm)
      t2c1 = fake_comment!(alice, t2)
      t2c2 = fake_comment!(bob, t2)
      threads = [{t1, [t1c2, t1c1]}, {t2, [t2c2, t2c1]}]
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()}
          threads {
            pageInfo { startCursor endCursor }
            totalCount
            edges {
              cursor
              node {
                #{thread_basics()}
                comments {
                  pageInfo { startCursor endCursor }
                  totalCount
                  edges {
                    cursor
                    node { #{comment_basics()} }
                  }
                }
              }
            }
          }
        }
      }
      """
      assert %{"community" => comm} = gql_post_data(%{query: q})
      comm = assert_community(comm)
      assert %{"threads" => threads2} = comm
      edge_list = assert_edge_list(threads2)
      assert Enum.count(edge_list.edges) == Enum.count(threads)
      for {{t,cs},edge} <- Enum.zip(threads, edge_list.edges) do
        t = assert_thread(t, edge.node)
        assert t.id == edge.cursor
        assert %{"comments" => comments2} = t
        edge_list = assert_edge_list(comments2)
        assert Enum.count(edge_list.edges) == Enum.count(cs)
        for {comment, edge} <- Enum.zip(cs, edge_list.edges) do
          assert edge["node"]["id"] == edge["cursor"]
          assert_comment(comment, edge["node"])
        end
      end
      assert threads2["totalCount"] == 2
    end
  end

  describe "community.followers" do

    test "works for a guest" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      {:ok, alice_follow} = Follows.one([:deleted, creator_id: alice.id, context_id: comm.id])
      {:ok, bob_follow} = Follows.create(bob, comm, %{is_local: true})
      {:ok, eve_follow} = Follows.create(eve, comm, %{is_local: true})
      folls = [eve_follow, bob_follow, alice_follow]
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()}
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
      assert %{"community" => comm} = gql_post_data(%{query: q})
      comm = assert_community(comm)
      assert %{"followers" => folls2} = comm
      edges = assert_edge_list(folls2).edges
      assert Enum.count(edges) == 3
      for {foll, edge} <- Enum.zip(folls, edges) do
        foll = assert_follow(foll, edge.node)
        assert foll.id == edge.cursor
      end
    end

    test "works for a user" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      mallory = fake_user!()
      conn = user_conn(mallory)
      {:ok, alice_follow} = Follows.one([:deleted, creator_id: alice.id, context_id: comm.id])
      {:ok, bob_follow} = Follows.create(bob, comm, %{is_local: true})
      {:ok, eve_follow} = Follows.create(eve, comm, %{is_local: true})
      folls = [eve_follow, bob_follow, alice_follow]
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()}
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
      assert %{"community" => comm} = gql_post_data(conn, %{query: q})
      comm = assert_community(comm)
      assert %{"followers" => folls2} = comm
      edges = assert_edge_list(folls2).edges
      assert Enum.count(edges) == 3
      for {foll, edge} <- Enum.zip(folls, edges) do
        foll = assert_follow(foll, edge.node)
        assert foll.id == edge.cursor
      end
    end

    test "works for an instance admin" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      mallory = fake_user!(%{is_instance_admin: true})
      conn = user_conn(mallory)
      {:ok, alice_follow} = Follows.one([:deleted, creator_id: alice.id, context_id: comm.id])
      {:ok, bob_follow} = Follows.create(bob, comm, %{is_local: true})
      {:ok, eve_follow} = Follows.create(eve, comm, %{is_local: true})
      folls = [eve_follow, bob_follow, alice_follow]
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()}
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
      assert %{"community" => comm} = gql_post_data(conn, %{query: q})
      comm = assert_community(comm)
      assert %{"followers" => folls2} = comm
      edges = assert_edge_list(folls2).edges
      assert Enum.count(edges) == 3
      for {foll,edge} <- Enum.zip(folls, edges) do
        foll = assert_follow(foll, edge.node)
        assert foll.id == edge.cursor
      end
    end
  end

  describe "community.outbox" do
    test "Works for self" do
      user = fake_user!()
      comm = fake_community!(user)
      conn = user_conn(user)
      query = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()}
          outbox { #{page_basics()} edges { cursor node { #{activity_basics()} } } }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(conn, %{query: query})
      comm2 = assert_community(comm, comm2)
      assert %{"outbox" => outbox} = comm2
      edge_list = assert_edge_list(outbox)
      # assert Enum.count(edge_list.edges) == 5
      for edge <- edge_list.edges do
        assert_activity(edge.node)
        assert is_binary(edge.cursor)
      end
    end
  end

  # describe "community.inbox" do
  #   @tag :skip
  #   test "placeholder" do
  #   end
  # end

  describe "community.flags" do

    test "empty for a guest with a public community" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      {:ok, _alice_flag} = Flags.create(alice, comm, %{is_local: true, message: "naughty"})
      {:ok, _bob_flag} = Flags.create(bob, comm, %{is_local: true, message: "naughty"})
      {:ok, _eve_flag} = Flags.create(eve, comm, %{is_local: true, message: "naughty"})
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()}
          flags {
            #{page_basics()}
            edges {
              cursor
              node {
                #{flag_basics()}
                context { ... on Community { #{community_basics()} } }
                creator { #{user_basics()} }
              }
            }
          }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(%{query: q})
      comm2 = assert_community(comm, comm2)
      assert %{"flags" => flags2} = comm2
      assert [] == assert_edge_list(flags2).edges
    end

    test "empty for a user with a public community" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      {:ok, _alice_flag} = Flags.create(alice, comm, %{is_local: true, message: "naughty"})
      {:ok, _bob_flag} = Flags.create(bob, comm, %{is_local: true, message: "naughty"})
      {:ok, _eve_flag} = Flags.create(eve, comm, %{is_local: true, message: "naughty"})
      mallory = fake_user!()
      conn = user_conn(mallory)
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()}
          flags {
            #{page_basics()}
            edges {
              cursor
              node {
                #{flag_basics()}
                context { ... on Community { #{community_basics()} } }
                creator { #{user_basics()} }
              }
            }
          }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(conn, %{query: q})
      comm2 = assert_community(comm, comm2)
      assert %{"flags" => flags2} = comm2
      assert [] == assert_edge_list(flags2).edges
    end

    test "works for a user who has flagged a public community" do
      alice = fake_user!()
      bob = fake_user!()
      eve = fake_user!()
      comm = fake_community!(alice)
      {:ok, _alice_flag} = Flags.create(alice, comm, %{is_local: true, message: "naughty"})
      {:ok, _bob_flag} = Flags.create(bob, comm, %{is_local: true, message: "naughty"})
      {:ok, eve_flag} = Flags.create(eve, comm, %{is_local: true, message: "naughty"})
      flags = [eve_flag]
      conn = user_conn(eve)
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()}
          flags {
            #{page_basics()}
            edges {
              cursor
              node {
                #{flag_basics()}
                context { ... on Community { #{community_basics()} } }
                creator { #{user_basics()} }
              }
            }
          }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(conn, %{query: q})
      comm2 = assert_community(comm, comm2)
      assert %{"flags" => flags2} = comm2
      edges = assert_edge_list(flags2).edges
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
      {:ok, alice_flag} = Flags.create(alice, comm, %{is_local: true, message: "naughty"})
      {:ok, bob_flag} = Flags.create(bob, comm, %{is_local: true, message: "naughty"})
      {:ok, eve_flag} = Flags.create(eve, comm, %{is_local: true, message: "naughty"})
      flags = [eve_flag, bob_flag, alice_flag]
      mallory = fake_user!(%{is_instance_admin: true})
      conn = user_conn(mallory)
      q = """
      { community(communityId: "#{comm.id}") {
          #{community_basics()}
          flags {
            #{page_basics()}
            edges {
              cursor
              node {
                #{flag_basics()}
                context { ... on Community { #{community_basics()} } }
                creator { #{user_basics()} }
              }
            }
          }
        }
      }
      """
      assert %{"community" => comm2} = gql_post_data(conn, %{query: q})
      comm2 = assert_community(comm, comm2)
      assert %{"flags" => flags2} = comm2
      edges = assert_edge_list(flags2).edges
      assert Enum.count(edges) == Enum.count(flags)
      for {flag, edge} <- Enum.zip(flags, edges) do
        assert_flag(flag, edge.node)
      end
    end
  end

end

