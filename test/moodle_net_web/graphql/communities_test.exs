# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommunityTest do
  use MoodleNetWeb.ConnCase, async: true
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNet.Test.Faking
  import MoodleNetWeb.Test.ConnHelpers
  alias MoodleNet.Test.Fake
  alias MoodleNet.{Actors, Localisation}

  import ActivityPub.Entity, only: [local_id: 1]
  import MoodleNet.MediaProxy.URLBuilder, only: [encode: 1]

  defp english(), do: Localisation.language!("en")

  defp assert_community_eq(orig, returned) do
    assert %{"id" => id, "name" => name} = returned
    assert orig.id == id
    assert orig.actor.current.name == name
    assert %{"summary" => summary, "preferredUsername" => username} = returned
    assert orig.actor.current.summary == summary
    assert orig.actor.preferred_username == username
    assert %{"icon" => icon, "image" => image} = returned
    assert orig.actor.current.icon == icon
    assert orig.actor.current.image == image
    assert %{"primaryLanguage" => primary_language} = returned
    assert orig.actor.primary_language_id == primary_language["id"]
  end

  defp assert_community_input_eq(orig, returned) do
    assert %{"name" => name, "summary" => summary} = returned
    assert orig["name"] == name
    assert orig["summary"] == summary
    assert %{"preferredUsername" => username} = returned
    assert orig["preferredUsername"] == username
    assert %{"icon" => icon, "image" => image} = returned
    assert orig["icon"] == icon
    assert orig["image"] == image
    assert %{"primaryLanguage" => primary_language} = returned
    assert %{"id" => pl_id} = primary_language
    assert orig["primaryLanguageId"] == pl_id
  end

  @community_basic_fields "id name summary preferredUsername icon image"

  @list_communities_query """
  { communities
    { totalCount
      pageinfo { startcursor endcursor }
      nodes
      { #{@community_basic_fields}
        primaryLanguage { id english_name local_name } } } }
  """

  @paginated_communities_query """
  { communities(limit: 1, offset: 2)
    { totalCount
      pageinfo { startcursor endcursor }
      nodes
      { #{@community_basic_fields}
        primaryLanguage { id english_name local_name } } } }
  """

  describe "CommunitiesResolver.list" do

    setup do
      user = fake_user!()
      c1 = fake_community!(user, %{is_public: true})
      c2 = fake_community!(user, %{is_public: true})
      c3 = fake_community!(user, %{is_public: false})
      c4 = fake_community!(user, %{is_public: true})
      {:ok, %{user: user, communities: [c4,c3,c2,c1]}}
    end

    @tag :skip
    test "Works for a guest", %{user: user, communities: communities} do
      conn = json_conn()
      query = @list_communities_query

      assert %{"communities" => comms} =
	gql_post_data(%{query: query}, "communities")

      assert page_info = comms["pageInfo"]
      assert start_cursor = page_info["startCursor"]
      assert end_cursor = page_info["endCursor"]
      assert 3 == comms["totalCount"]
      assert nodes = comms["nodes"]
      assert is_list(nodes)
      assert 3 == Enum.count(nodes)
      # todo: check the correct collections are returned
    end

    @tag :skip
    test "Works for a logged in user", %{user: user, communities: communities} do
      # user = fake_user!()
      # conn = user_conn(user)
      # assert %{"communities" => comms} =
      # 	gql_post_data(conn, %{query: query}, "communities")
    end

    @tag :skip
    test "Paginates correctly" do
      # user = fake_user!()
      # query = @paginated_communities_query
      # assert %{"communities" => comms} =
      # 	gql_post_data(%{query: query}, "communities")
    end

  end


  describe "CommunitiesResolver.fetch" do

    test "works for a guest" do
      user = fake_user!()
      comm = fake_community!(user, %{is_public: true})
      query = """
      { community(communityId: "#{comm.id}")
        { #{@community_basic_fields}
          primaryLanguage { id english_name local_name } } }
      """
      assert %{"community" => comm2} = gql_post_data(json_conn(), %{query: query})
      assert_community_eq(comm, comm2)
    end

    test "works for a user" do
      user = fake_user!()
      comm = fake_community!(user, %{is_public: true})
      conn = user_conn(user)
      query = """
      { community(communityId: "#{comm.id}")
        { #{@community_basic_fields}
          primaryLanguage { id english_name local_name } } }
      """
      assert %{"community" => comm2} = gql_post_data(conn, %{query: query})
      assert_community_eq(comm, comm2)
    end

    @tag :skip
    @todo :post_moot
    test "doesn't work for a private community" do
      user = fake_user!()
      comm = fake_community!(user, %{is_public: false})
      query = """
      { community(communityId: "#{comm.id}")
        { #{@community_basic_fields}
          primaryLanguage { id english_name local_name } } }
      """
      assert errors = gql_post_errors(json_conn(), %{query: query})
    end

  end

  describe "CommunitiesResolver.create" do

    test "Works for a logged in user" do
      user = fake_user!()
      conn = user_conn(user)
      query = """
      mutation Test($community: CommunityInput) {
        createCommunity(community: $community) {
          #{@community_basic_fields}
          primaryLanguage { id english_name local_name }
        }
      }
      """
      input = Fake.community_input()
      vars = %{"community" => input}
      query = %{operationName: "Test", query: query, variables: vars}
      assert %{"createCommunity" => comm2} = gql_post_data(conn, query)
      
      assert_community_input_eq(input, comm2)
      
      # TODO: check creates a follow for the creator
    end

    test "Does not work for a guest" do
      query = """
      mutation Test($community: CommunityInput) {
        createCommunity(community: $community) {
          #{@community_basic_fields}
          primaryLanguage { id english_name local_name }
        }
      }
      """
      input = Fake.community_input()
      vars = %{"community" => input}
      query = %{operationName: "Test", query: query, variables: vars}
      assert errs = gql_post_errors(json_conn(), query)
      assert_not_logged_in(errs, ["createCommunity"])
    end

  end

  describe "CommunitiesResolver.update" do
    @tag :skip
    test "works for the creator of the community" do
    end
    @tag :skip
    test "doesn't work for a non-creator" do
    end
    @tag :skip
    test "doesn't work for a guest" do
    end
    
  end

  describe "CommunitiesResolver.delete" do

    setup do
      owner = fake_user!()
      comm = fake_community!(owner)
      {:ok, %{owner: owner, community: comm}}
    end


    test "works for the creator of the community", ctx do
      conn = user_conn(ctx.owner)
      query = """
      mutation { deleteCommunity(communityId: "#{ctx.community.id}") }
      """
      assert true == Map.fetch!(gql_post_data(conn, %{query: query}), "deleteCommunity")      
    end

    test "doesn't work for a non-creator", ctx do
      user = fake_user!()
      conn = user_conn(user)
      query = """
      mutation { deleteCommunity(communityId: "#{ctx.community.id}") }
      """
      assert errs = gql_post_errors(conn, %{query: query})
      assert_not_permitted(errs, ["deleteCommunity"])
    end

    test "doesn't work for a guest", ctx do
      query = """
      mutation { deleteCommunity(communityId: "#{ctx.community.id}") }
      """
      assert errs = gql_post_errors(json_conn(), %{query: query})
      assert_not_logged_in(errs, ["deleteCommunity"])
    end
  end
  
  # @tag :user
  # test "community list", %{conn: conn, actor: actor} do
  #   query = """
  #     {
  #       communities {
  #         pageInfo {
  #           startCursor
  #           endCursor
  #         }
  #         nodes {
  #           id
  #           name
  #           collections {
  #             totalCount
  #           }
  #         }
  #         totalCount
  #       }
  #     }
  #   """

  #   assert ret =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("communities")

  #   assert %{
  #            "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
  #            "nodes" => [],
  #            "totalCount" => 0
  #          } = ret

  #   %{id: a_id} = Factory.community(actor)
  #   %{id: b_id} = Factory.community(actor)

  #   assert ret =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("communities")

  #   assert %{
  #            "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
  #            "nodes" => nodes,
  #            "totalCount" => 2
  #          } = ret

  #   assert [%{"id" => ^b_id}, %{"id" => ^a_id}] = nodes
  # end


  # @tag :user
  # test "collection connection", %{conn: conn, actor: actor} do
  #   community = Factory.community(actor)
  #   local_id = local_id(community)

  #   query = """
  #     {
  #       community(localId: #{local_id}) {
  #         collections {
  #           pageInfo {
  #             startCursor
  #             endCursor
  #           }
  #           edges {
  #             cursor
  #             node {
  #               id
  #               resources {
  #                 totalCount
  #               }
  #             }
  #           }
  #           totalCount
  #         }
  #       }
  #     }
  #   """

  #   assert ret =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("community")
  #            |> Map.fetch!("collections")

  #   assert %{
  #            "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
  #            "edges" => [],
  #            "totalCount" => 0
  #          } = ret

  #   %{id: a_id} = Factory.collection(actor, community)
  #   %{id: b_id} = Factory.collection(actor, community)

  #   assert ret =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("community")
  #            |> Map.fetch!("collections")

  #   assert %{
  #            "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
  #            "edges" => edges,
  #            "totalCount" => 2
  #          } = ret

  #   assert [
  #            %{
  #              "cursor" => cursor_b,
  #              "node" => %{
  #                "id" => ^b_id
  #              }
  #            },
  #            %{
  #              "cursor" => cursor_a,
  #              "node" => %{
  #                "id" => ^a_id
  #              }
  #            }
  #          ] = edges

  #   assert cursor_a
  #   assert cursor_b
  #   assert cursor_b > cursor_a
  # end

  # @tag :user
  # test "thread connection", %{conn: conn, actor: actor} do
  #   community = Factory.community(actor)
  #   local_id = local_id(community)

  #   query = """
  #     {
  #       community(localId: #{local_id}) {
  #         threads {
  #           pageInfo {
  #             startCursor
  #             endCursor
  #           }
  #           edges {
  #             cursor
  #             node {
  #               id
  #             }
  #           }
  #           totalCount
  #         }
  #       }
  #     }
  #   """

  #   assert ret =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("community")
  #            |> Map.fetch!("threads")

  #   assert %{
  #            "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
  #            "edges" => [],
  #            "totalCount" => 0
  #          } = ret

  #   %{id: a_id} = Factory.comment(actor, community)
  #   %{id: b_id} = Factory.comment(actor, community)

  #   assert ret =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("community")
  #            |> Map.fetch!("threads")

  #   assert %{
  #            "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
  #            "edges" => edges,
  #            "totalCount" => 2
  #          } = ret

  #   assert [
  #            %{
  #              "cursor" => cursor_b,
  #              "node" => %{
  #                "id" => ^b_id
  #              }
  #            },
  #            %{
  #              "cursor" => cursor_a,
  #              "node" => %{
  #                "id" => ^a_id
  #              }
  #            }
  #          ] = edges

  #   assert cursor_a
  #   assert cursor_b
  #   assert cursor_b > cursor_a
  # end

  # @tag :user
  # test "members", %{conn: conn, actor: actor} do
  #   community = Factory.community(actor)
  #   local_id = local_id(community)

  #   query = """
  #   {
  #     community(local_id: #{local_id}) {
  #       members {
  #         pageInfo {
  #           startCursor
  #           endCursor
  #         }
  #         edges {
  #           cursor
  #           node {
  #             id
  #             localId
  #             name
  #           }
  #         }
  #         totalCount
  #       }
  #     }
  #   }
  #   """

  #   assert members =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("community")
  #            |> Map.fetch!("members")

  #   assert %{
  #            "pageInfo" => %{
  #              "startCursor" => nil,
  #              "endCursor" => nil
  #            },
  #            "edges" => [
  #              %{
  #                "cursor" => cursor,
  #                "node" => actor_map
  #              }
  #            ],
  #            "totalCount" => 1
  #          } = members
  # end

  # @tag :user
  # test "join_community & undo", %{conn: conn, actor: actor} do
  #   community = Factory.community(actor)
  #   community_local_id = local_id(community)

  #   query = """
  #   {
  #     community(localId: #{community_local_id}) {
  #       id
  #       localId
  #       followed
  #       members {
  #         totalCount
  #         edges {
  #           node {
  #             id
  #           }
  #         }
  #       }
  #     }
  #   }
  #   """

  #   assert community_map =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("community")

  #   assert community_map["id"] == community.id
  #   assert community_map["localId"] == community_local_id
  #   assert community_map["followed"] == true

  #   assert %{
  #            "totalCount" => 1,
  #            "edges" => [
  #              %{
  #                "node" => user_map
  #              }
  #            ]
  #          } = community_map["members"]

  #   assert user_map["id"] == actor.id

  #   query = """
  #     mutation {
  #       undoJoinCommunity(
  #         communityLocalId: #{community_local_id}
  #       )
  #     }
  #   """

  #   assert conn
  #          |> post("/api/graphql", %{query: query})
  #          |> json_response(200)
  #          |> Map.fetch!("data")
  #          |> Map.fetch!("undoJoinCommunity")

  #   assert [
  #            %{
  #              "code" => "not_found",
  #              "message" => "Activity not found"
  #            }
  #          ] =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("errors")

  #   query = """
  #   {
  #     community(localId: #{community_local_id}) {
  #       id
  #       localId
  #       followed
  #       members {
  #         totalCount
  #         edges {
  #           node {
  #             id
  #           }
  #         }
  #       }
  #     }
  #   }
  #   """

  #   assert community_map =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("community")

  #   assert community_map["id"] == community.id
  #   assert community_map["localId"] == community_local_id
  #   assert community_map["followed"] == false

  #   assert %{
  #            "totalCount" => 0,
  #            "edges" => []
  #          } = community_map["members"]

  #   query = """
  #     mutation {
  #       joinCommunity(
  #         communityLocalId: #{community_local_id}
  #       )
  #     }
  #   """

  #   assert conn
  #          |> post("/api/graphql", %{query: query})
  #          |> json_response(200)
  #          |> Map.fetch!("data")
  #          |> Map.fetch!("joinCommunity")

  #   query = """
  #   {
  #     community(localId: #{community_local_id}) {
  #       id
  #       localId
  #       followed
  #       members {
  #         totalCount
  #         edges {
  #           node {
  #             id
  #           }
  #         }
  #       }
  #     }
  #   }
  #   """

  #   assert community_map =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("community")

  #   assert community_map["id"] == community.id
  #   assert community_map["localId"] == community_local_id
  #   assert community_map["followed"] == true

  #   assert %{
  #            "totalCount" => 1,
  #            "edges" => [
  #              %{
  #                "node" => user_map
  #              }
  #            ]
  #          } = community_map["members"]

  #   assert user_map["id"] == actor.id
  # end

  # @tag :user
  # test "delete a community", %{conn: conn, actor: actor} do
  #   community = Factory.community(actor)
  #   collection = Factory.collection(actor, community)
  #   resource = Factory.resource(actor, collection)
  #   com_comment = Factory.comment(actor, community)
  #   col_comment = Factory.comment(actor, collection)
  #   reply = Factory.reply(actor, com_comment)

  #   query = """
  #   mutation {
  #     deleteCommunity(localId: #{local_id(community)})
  #   }
  #   """

  #   assert true ==
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("deleteCommunity")

  #   assert nil == ActivityPub.SQL.Query.get_by_id(community.id)
  #   assert nil == ActivityPub.SQL.Query.get_by_id(collection.id)
  #   assert nil == ActivityPub.SQL.Query.get_by_id(resource.id)
  #   assert nil == ActivityPub.SQL.Query.get_by_id(com_comment.id)
  #   assert nil == ActivityPub.SQL.Query.get_by_id(col_comment.id)
  #   assert nil == ActivityPub.SQL.Query.get_by_id(reply.id)
  # end

  # @tag :user
  # test "update community", %{conn: conn, actor: actor} do
  #   community = Factory.community(actor)

  #   query = """
  #     mutation {
  #       updateCommunity(
  #         community_local_id: #{local_id(community)}
  #         community: {
  #           name: "community_name"
  #           summary: "community_summary"
  #           content:"community_content"
  #           preferredUsername: "community_preferredUser"
  #           primaryLanguage:"community_language"
  #           icon:"https://imag.es/community"
  #         }
  #       ) {
  #         id
  #         localId
  #         name
  #         summary
  #         content
  #         preferredUsername
  #         primaryLanguage
  #         icon
  #         published
  #         updated
  #       }
  #     }
  #   """

  #   assert ret_community =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("updateCommunity")

  #   assert ret_community["id"] == community.id
  #   assert ret_community["localId"]
  #   assert ret_community["published"]
  #   assert ret_community["updated"]
  #   assert ret_community["name"] == "community_name"
  #   assert ret_community["summary"] == "community_summary"
  #   assert ret_community["content"] == "community_content"
  #   assert ret_community["preferredUsername"] == "community_preferredUser"
  #   assert ret_community["primaryLanguage"] == "community_language"
  #   assert ret_community["icon"] == encode("https://imag.es/community")

  #   query = """
  #   {
  #     community(local_id: #{local_id(community)}) {
  #       id
  #       localId
  #       name
  #       summary
  #       content
  #       preferredUsername
  #       primaryLanguage
  #       icon
  #       published
  #       updated
  #     }
  #   }
  #   """

  #   assert ret_community_2 =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("community")

  #   assert ret_community == ret_community_2
  # end

  # @tag :user
  # test "inbox connection", %{conn: conn, actor: actor} do
  #   community = Factory.community(actor)
  #   MoodleNet.update_community(actor, community, %{name: "Name"})

  #   collection = Factory.collection(actor, community)
  #   MoodleNet.update_collection(actor, collection, %{name: "Name"})

  #   resource = Factory.resource(actor, collection)
  #   MoodleNet.update_resource(actor, resource, %{name: "Name"})

  #   comment = Factory.comment(actor, community)
  #   Factory.reply(actor, comment)

  #   local_id = local_id(community)

  #   query = """
  #     {
  #       community(localId: #{local_id}) {
  #         inbox {
  #           pageInfo {
  #             startCursor
  #             endCursor
  #           }
  #           edges {
  #             cursor
  #             node {
  #               id
  #               activityType
  #             }
  #           }
  #           totalCount
  #         }
  #       }
  #     }
  #   """

  #   assert ret =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("community")
  #            |> Map.fetch!("inbox")

  #   assert %{
  #            "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
  #            "edges" => edges,
  #            "totalCount" => 8
  #          } = ret

  #   assert [
  #            %{
  #              "node" => %{
  #                "activityType" => "CreateComment"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "CreateComment"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "UpdateResource"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "CreateResource"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "UpdateCollection"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "CreateCollection"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "UpdateCommunity"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "JoinCommunity"
  #              }
  #            }
  #          ] = edges
  # end
end
