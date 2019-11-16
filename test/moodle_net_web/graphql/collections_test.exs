# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CollectionsTest do
  # use MoodleNetWeb.ConnCase, async: true
  # import MoodleNetWeb.Test.GraphQLAssertions
  # import MoodleNet.Test.Faking
  # import MoodleNetWeb.Test.ConnHelpers
  # alias MoodleNet.Test.Fake
  # alias MoodleNet.{Collections, Communities, Users}

  # defp assert_collection_eq(orig, returned) do
  #   assert %{"id" => id, "name" => name, "content" => content} = returned
  #   assert orig.id == id
  #   assert orig.name == name
  #   assert orig.content == content
  #   assert %{"summary" => summary, "icon" => icon} = returned
  #   assert orig.summary == summary
  #   assert orig.icon == icon
  #   assert %{"primaryLanguage" => primary_language} = returned
  #   assert orig.primary_language_id == primary_language["id"]
  # end
  
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
