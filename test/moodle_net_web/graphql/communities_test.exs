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

  describe "communities" do
    @tag :skip
    test "placeholder" do
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
    @tag :skip
    test "placeholder" do
    end
  end

  describe "community.myFollow" do
    @tag :skip
    test "placeholder" do
    end
  end

  describe "community.creator" do
    @tag :skip
    test "placeholder" do
    end
  end

  describe "community.collections" do
    test "works for a guest" do
      alice = fake_user!()
      comm = fake_community!(alice)
      colls = Enum.map(1..5, fn _ -> fake_collection!(alice, comm) end)
      q = """
      { community(communityId: #{}) {
          collections {
            pageInfo { startCursor endCursor }
            totalCount
            nodes { #{collection_basics()} }
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
	assert edge.cursor == coll.created_at
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
    @tag :skip
    test "placeholder" do
    end
  end

  # describe "community.inbox" do
  #   @tag :skip
  #   test "placeholder" do
  #   end
  # end


end

