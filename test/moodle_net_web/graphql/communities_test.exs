# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommunityTest do
  # use MoodleNetWeb.ConnCase, async: true
  # import MoodleNetWeb.Test.GraphQLAssertions
  # import MoodleNet.Test.Faking
  # import MoodleNetWeb.Test.ConnHelpers
  # alias MoodleNet.Test.Fake
  # alias MoodleNet.{Actors, Collections, Communities, Localisation}

  # import ActivityPub.Entity, only: [local_id: 1]
  # import MoodleNet.MediaProxy.URLBuilder, only: [encode: 1]

  # defp assert_community_eq(orig, returned) do
  #   assert %{"id" => id, "name" => name} = returned
  #   assert orig.actor.id == id
  #   assert orig.actor.current.name == name
  #   assert %{"summary" => summary, "preferredUsername" => username} = returned
  #   assert orig.actor.current.summary == summary
  #   assert orig.actor.preferred_username == username
  #   assert %{"icon" => icon, "image" => image} = returned
  #   assert orig.actor.current.icon == icon
  #   assert orig.actor.current.image == image
  #   assert %{"primaryLanguage" => primary_language} = returned
  #   assert orig.actor.primary_language_id == primary_language["id"]
  # end

  # defp assert_community_input_eq(orig, returned) do
  #   assert %{"name" => name, "summary" => summary} = returned
  #   assert orig["name"] == name
  #   assert orig["summary"] == summary
  #   assert %{"preferredUsername" => username} = returned
  #   assert orig["preferredUsername"] == username
  #   assert %{"icon" => icon, "image" => image} = returned
  #   assert orig["icon"] == icon
  #   assert orig["image"] == image
  #   assert %{"primaryLanguage" => primary_language} = returned
  #   assert %{"id" => pl_id} = primary_language
  #   assert orig["primaryLanguageId"] == pl_id
  # end

  # @community_basic_fields "id name summary preferredUsername icon image"

  # @list_query """
  # { communities
  #   { totalCount
  #     pageInfo { startCursor endCursor }
  #     nodes
  #     { #{@community_basic_fields}
  #       primaryLanguage { id englishName localName } } } }
  # """

  # describe "CommunitiesResolver.list" do

  #   test "Works for a guest" do
  #     alice = fake_user!()
  #     comm_1 = fake_community!(alice)
  #     comm_2 = fake_community!(alice)
  #     bob = fake_user!()
  #     comm_3 = fake_community!(bob)
  #     comm_4 = fake_community!(bob)
  #     comm_5 = fake_community!(bob)
  #     assert %{"communities" => ret} =
  # 	gql_post_data(json_conn(), %{query: @list_query})
  #     assert %{"pageInfo" => info, "nodes" => nodes, "totalCount" => count} = ret
  #     assert is_list(nodes)
  #     assert count == 5
  #     assert Enum.count(nodes) == 5
  #     assert info
  #     assert start_cursor = info["startCursor"]
  #     assert end_cursor = info["endCursor"]
  #   end

  #   test "Works for a logged in user" do
  #     alice = fake_user!()
  #     comm_1 = fake_community!(alice)
  #     comm_2 = fake_community!(alice)
  #     bob = fake_user!()
  #     comm_3 = fake_community!(bob)
  #     comm_4 = fake_community!(bob)
  #     comm_5 = fake_community!(bob)
  #     eve = fake_user!()
  #     conn = user_conn(eve)
  #     assert %{"communities" => ret} =
  # 	gql_post_data(conn, %{query: @list_query})
  #     assert %{"pageInfo" => info, "nodes" => nodes, "totalCount" => count} = ret
  #     assert is_list(nodes)
  #     assert count == 5
  #     assert Enum.count(nodes) == 5
  #     assert info
  #     assert start_cursor = info["startCursor"]
  #     assert end_cursor = info["endCursor"]
  #   end

  #   @tag :skip
  #   test "Paginates correctly" do
  #   end

  # end


  # describe "CommunitiesResolver.fetch" do

  #   test "works for a guest" do
  #     user = fake_user!()
  #     comm = fake_community!(user, %{is_public: true})
  #     query = """
  #     { community(communityId: "#{comm.actor.id}")
  #       { #{@community_basic_fields}
  #         primaryLanguage { id englishName localName } } }
  #     """
  #     assert %{"community" => comm2} = gql_post_data(json_conn(), %{query: query})
  #     assert_community_eq(comm, comm2)
  #   end

  #   test "works for a user" do
  #     user = fake_user!()
  #     comm = fake_community!(user, %{is_public: true})
  #     conn = user_conn(user)
  #     query = """
  #     { community(communityId: "#{comm.actor.id}")
  #       { #{@community_basic_fields}
  #         primaryLanguage { id englishName localName } } }
  #     """
  #     assert %{"community" => comm2} = gql_post_data(conn, %{query: query})
  #     assert_community_eq(comm, comm2)
  #   end

  #   # @tag :skip
  #   # @for_moot false
  #   # test "doesn't work for a private community" do
  #   #   user = fake_user!()
  #   #   comm = fake_community!(user, %{is_public: false}) # ignored today
  #   #   query = """
  #   #   { community(communityId: "#{comm.id}")
  #   #     { #{@community_basic_fields}
  #   #       primaryLanguage { id englishName localName } } }
  #   #   """
  #   #   assert errors = gql_post_errors(json_conn(), %{query: query})
  #   #   assert_not_found(errors, ["community"])
  #   # end

  # end

  # describe "CommunitiesResolver.create" do

  #   test "Works for a logged in user" do
  #     user = fake_user!()
  #     conn = user_conn(user)
  #     query = """
  #     mutation Test($community: CommunityInput) {
  #       createCommunity(community: $community) {
  #         #{@community_basic_fields}
  #         primaryLanguage { id englishName localName }
  #       }
  #     }
  #     """
  #     input = Fake.community_input()
  #     vars = %{"community" => input}
  #     query = %{operationName: "Test", query: query, variables: vars}
  #     assert %{"createCommunity" => comm2} = gql_post_data(conn, query)
      
  #     assert_community_input_eq(input, comm2)
      
  #     # TODO: check creates a follow for the creator
  #   end

  #   test "Does not work for a guest" do
  #     query = """
  #     mutation Test($community: CommunityInput) {
  #       createCommunity(community: $community) {
  #         #{@community_basic_fields}
  #         primaryLanguage { id englishName localName }
  #       }
  #     }
  #     """
  #     input = Fake.community_input()
  #     vars = %{"community" => input}
  #     query = %{operationName: "Test", query: query, variables: vars}
  #     assert errs = gql_post_errors(json_conn(), query)
  #     assert_not_logged_in(errs, ["createCommunity"])
  #   end

  # end

  # describe "CommunitiesResolver.update" do
  #   @tag :skip
  #   test "works for the creator of the community" do
  #   end
  #   @tag :skip
  #   test "doesn't work for a non-creator" do
  #   end
  #   @tag :skip
  #   test "doesn't work for a guest" do
  #   end
    
  # end

  # describe "CommunitiesResolver.delete" do

  #   setup do
  #     owner = fake_user!()
  #     comm = fake_community!(owner)
  #     {:ok, %{owner: owner, community: comm}}
  #   end


  #   test "works for the creator of the community", ctx do
  #     conn = user_conn(ctx.owner)
  #     query = """
  #     mutation { deleteCommunity(communityId: "#{ctx.community.actor.id}") }
  #     """
  #     assert %{"deleteCommunity" => true} == gql_post_data(conn, %{query: query})
  #   end

  #   test "doesn't work for a non-creator", ctx do
  #     user = fake_user!()
  #     conn = user_conn(user)
  #     query = """
  #     mutation { deleteCommunity(communityId: "#{ctx.community.actor.id}") }
  #     """
  #     assert errs = gql_post_errors(conn, %{query: query})
  #     assert_not_permitted(errs, ["deleteCommunity"])
  #   end

  #   test "doesn't work for a guest", ctx do
  #     query = """
  #     mutation { deleteCommunity(communityId: "#{ctx.community.actor.id}") }
  #     """
  #     assert errs = gql_post_errors(json_conn(), %{query: query})
  #     assert_not_logged_in(errs, ["deleteCommunity"])
  #   end
  # end
  
  # describe "CommunitiesResolver.collections" do

  #   test "works for a guest" do
  #     alice = fake_user!()
  #     comm_1 = fake_community!(alice)
  #     coll_1 = fake_collection!(alice, comm_1)
  #     coll_2 = fake_collection!(alice, comm_1)
  #     bob = fake_user!()
  #     comm_2 = fake_community!(bob)
  #     coll_3 = fake_collection!(bob, comm_2)
  #     eve = fake_user!()
  #     conn = user_conn(eve)
  #     query = """
  #     { community(communityId: "#{comm_1.actor.id}") {
  #         collections { 
  #           pageInfo { startCursor endCursor }
  #           totalCount
  #           edges { cursor node { id } } } } }
  #     """
  #     assert %{"community" => comm} = gql_post_data(conn, %{query: query})
  #     assert %{"collections" => ret} = comm
  #     assert %{"pageInfo" => info, "edges" => edges, "totalCount" => count} = ret
  #     assert is_list(edges)
  #     assert Enum.count(edges) == 2
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
  #     query = """
  #     { community(communityId: "#{comm_1.actor.id}") {
  #         collections { 
  #           pageInfo { startCursor endCursor }
  #           totalCount
  #           edges { cursor node { id } } } } }
  #     """
  #     assert %{"community" => comm} = gql_post_data(conn, %{query: query})
  #     assert %{"collections" => ret} = comm
  #     assert %{"pageInfo" => info, "edges" => edges, "totalCount" => count} = ret
  #     assert is_list(edges)
  #     assert Enum.count(edges) == 1
  #   end

  # end

  # describe "CommunitiesResolver.creator" do

  #   setup do
  #     alice = fake_user!()
  #     community = fake_community!(alice)
  #     {:ok, alice: alice, community: community}
  #   end

  #   test "works for a guest", ctx do
  #     query = """
  #     { community(communityId: "#{ctx.community.actor.id}") { creator { id } } }
  #     """
  #     assert %{"community" => comm} = gql_post_data(json_conn(), %{query: query})
  #     assert %{"creator" => creator} = comm
  #     assert %{"id" => id} = creator
  #     assert id == ctx.alice.actor.id
  #   end

  #   test "works for a user", ctx do
  #     bob = fake_user!()
  #     conn = user_conn(bob)
  #     query = """
  #     { community(communityId: "#{ctx.community.actor.id}") { creator { id } } }
  #     """
  #     assert %{"community" => comm} = gql_post_data(json_conn(), %{query: query})
  #     assert %{"creator" => creator} = comm
  #     assert %{"id" => id} = creator
  #     assert id == ctx.alice.actor.id
  #   end

  #   test "works for the community creator", ctx do
  #     conn = user_conn(ctx.alice)
  #     query = """
  #     { community(communityId: "#{ctx.community.actor.id}") { creator { id } } }
  #     """
  #     assert %{"community" => comm} = gql_post_data(json_conn(), %{query: query})
  #     assert %{"creator" => creator} = comm
  #     assert %{"id" => id} = creator
  #     assert id == ctx.alice.actor.id
  #   end

  # end

  # describe "CommunitiesResolver.threads" do

  #   setup do
  #     alice = fake_user!()
  #     community = fake_community!(alice)
  #     {:ok, alice: alice, community: community}
  #   end

  #   @tag :skip
  #   @for_moot true
  #   test "works for a guest", ctx do
  #   end

  #   @tag :skip
  #   @for_moot true
  #   test "works for a user", ctx do
  #   end

  #   @tag :skip
  #   @for_moot true
  #   test "works for the community creator", ctx do
  #   end

  # end
  # describe "CommunitiesResolver.inbox" do

  #   setup do
  #     alice = fake_user!()
  #     community = fake_community!(alice)
  #     {:ok, alice: alice, community: community}
  #   end

  #   @tag :skip
  #   @for_moot true
  #   test "works for a guest", ctx do
  #   end

  #   @tag :skip
  #   @for_moot true
  #   test "works for a user", ctx do
  #   end

  #   @tag :skip
  #   @for_moot true
  #   test "works for the community creator", ctx do
  #   end

  # end
  # describe "CommunitiesResolver.outbox" do

  #   setup do
  #     alice = fake_user!()
  #     community = fake_community!(alice)
  #     {:ok, alice: alice, community: community}
  #   end

  #   @tag :skip
  #   @for_moot true
  #   test "works for a guest", ctx do
  #   end

  #   @tag :skip
  #   @for_moot true
  #   test "works for a user", ctx do
  #   end

  #   @tag :skip
  #   @for_moot true
  #   test "works for the community creator", ctx do
  #   end

  # end

end

