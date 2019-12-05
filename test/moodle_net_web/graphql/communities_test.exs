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
  alias MoodleNet.Common

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
          #{page_basics()} nodes { #{community_basics()} }
        }
      }
      """
      assert %{"communities" => comms2} = gql_post_data(%{query: q})
      node_list = assert_node_list(comms2)
      assert Enum.count(node_list.nodes) == 5
      for node <- node_list.nodes do
	assert_community(keyed[node["id"]], node)
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
          #{page_basics()} nodes {
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

    test "works for guest" do
      user = fake_user!()
      comm = fake_community!(user)
      q = """
      { community(communityId: "#{comm.id}") { #{community_basics()} } }
      """
      query = %{query: q}
      assert %{"community" => comm2} = gql_post_data(query)
      assert_community(comm, comm2)
    end

    test "works for user" do
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

    test "works for creator" do
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

  describe "community.myFollow" do
    test "works for followed for user" do
      alice = fake_user!()
      comm = fake_community!(alice)
      bob = fake_user!()
      conn = user_conn(bob)
      {:ok, follow} = Common.follow(bob, comm, %{is_local: true})
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

    test "works for unfollowed for user" do
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

    test "nil for guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      bob = fake_user!()
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
      colls = Enum.map(1..5, fn _ -> fake_collection!(alice, comm) end)
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
      edge_list = assert_edge_list(colls, &(&1.id))
      assert Enum.count(edge_list.edges) == 5
      for edge <- edge_list.edges do
	coll = assert_collection(edge.node)
	assert coll.id == edge.cursor
      end
    end
  end

  describe "community.threads" do
    @tag :skip
    test "placeholder" do
    end
  end

  describe "community.followers" do
    @tag :skip
    test "placeholder" do
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
	activity = assert_activity(edge.node)
	assert is_binary(edge.cursor)
      end
    end
  end

  # describe "community.inbox" do
  #   @tag :skip
  #   test "placeholder" do
  #   end
  # end


end

