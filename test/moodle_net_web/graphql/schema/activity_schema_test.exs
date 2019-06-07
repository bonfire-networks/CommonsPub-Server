# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.ActivitySchemaTest do
  use MoodleNetWeb.ConnCase

  @moduletag format: :json

  @tag :user
  describe "local activity list" do
    def query(limit \\ 100) do
      """
        {
          localActivities(limit: #{limit}) {
            pageInfo {
              startCursor
              endCursor
            }
            nodes {
              activityType
              id
              user {
                id
                name
                preferredUsername
                joinedCommunities { totalCount }
              }
              object {
                __typename
                ... on Community {
                  id
                  name
                  preferredUsername
                  members { totalCount }
                }
                ... on Collection {
                  id
                  name
                  preferredUsername
                  resources { totalCount }
                }
                ... on Resource {
                  id
                  learningResourceType
                }
                ... on Comment {
                  id
                  replies { totalCount }
                }
              }
            }
            totalCount
          }
        }
      """
    end

    test "community activities", %{conn: conn, actor: actor} do
      assert ret =
               conn
               |> post("/api/graphql", %{query: query()})
               |> json_response(200)
               |> Map.fetch!("data")
               |> Map.fetch!("localActivities")

      assert %{
               "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
               "nodes" => [],
               "totalCount" => 0
             } = ret

      %{id: community_id} = Factory.community(actor)
      # %{id: b_id} = Factory.community(actor)

      assert ret =
               conn
               |> post("/api/graphql", %{query: query()})
               |> json_response(200)
               |> Map.fetch!("data")
               |> Map.fetch!("localActivities")

      assert %{
               "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
               "nodes" => [follow, create],
               "totalCount" => 2
             } = ret

      actor_id = actor.id

      assert %{
               "activityType" => "JoinCommunity",
               "object" => %{
                 "__typename" => "Community",
                 "id" => ^community_id,
                 "members" => %{"totalCount" => 1}
               },
               "user" => %{"id" => ^actor_id}
             } = follow

      assert %{
               "activityType" => "CreateCommunity",
               "object" => %{
                 "__typename" => "Community",
                 "id" => ^community_id,
                 "members" => %{"totalCount" => 1}
               },
               "user" => %{"id" => ^actor_id}
             } = create

      MoodleNet.Accounts.delete_user(actor)

      assert ret =
               conn
               |> post("/api/graphql", %{query: query()})
               |> json_response(200)
               |> Map.fetch!("data")
               |> Map.fetch!("localActivities")

      assert %{
               "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
               "nodes" => [%{"user" => nil}, %{"user" => nil}],
               "totalCount" => 2
             } = ret
    end

    @tag :user
    test "collection activities", %{conn: conn, actor: actor} do
      community = Factory.community(actor)
      collection = %{id: collection_id} = Factory.collection(actor, community)
      MoodleNet.like_collection(actor, collection)

      assert ret =
               conn
               |> post("/api/graphql", %{query: query(3)})
               |> json_response(200)
               |> Map.fetch!("data")
               |> Map.fetch!("localActivities")

      assert %{
               "pageInfo" => %{"startCursor" => nil, "endCursor" => endCursor},
               "nodes" => [like, follow, create]
             } = ret

      assert endCursor
      actor_id = actor.id

      assert %{
               "activityType" => "LikeCollection",
               "object" => %{
                 "__typename" => "Collection",
                 "id" => ^collection_id,
                 "resources" => %{"totalCount" => 0}
               },
               "user" => %{"id" => ^actor_id}
             } = like

      assert %{
               "activityType" => "FollowCollection",
               "object" => %{
                 "__typename" => "Collection",
                 "id" => ^collection_id,
                 "resources" => %{"totalCount" => 0}
               },
               "user" => %{"id" => ^actor_id}
             } = follow

      assert %{
               "activityType" => "CreateCollection",
               "object" => %{
                 "__typename" => "Collection",
                 "id" => ^collection_id,
                 "resources" => %{"totalCount" => 0}
               },
               "user" => %{"id" => ^actor_id}
             } = create
    end

    @tag :user
    test "resource activities", %{conn: conn, actor: actor} do
      community = Factory.community(actor)
      collection = Factory.collection(actor, community)
      resource = %{id: resource_id} = Factory.resource(actor, collection)
      MoodleNet.like_resource(actor, resource)

      assert ret =
               conn
               |> post("/api/graphql", %{query: query(2)})
               |> json_response(200)
               |> Map.fetch!("data")
               |> Map.fetch!("localActivities")

      assert %{
               "pageInfo" => %{"startCursor" => nil, "endCursor" => endCursor},
               "nodes" => [like, create]
             } = ret

      assert endCursor
      actor_id = actor.id

      assert %{
               "activityType" => "LikeResource",
               "object" => %{
                 "__typename" => "Resource",
                 "id" => ^resource_id,
                 "learningResourceType" => "?"
               },
               "user" => %{"id" => ^actor_id}
             } = like

      assert %{
               "activityType" => "CreateResource",
               "object" => %{
                 "__typename" => "Resource",
                 "id" => ^resource_id,
                 "learningResourceType" => "?"
               },
               "user" => %{"id" => ^actor_id}
             } = create
    end

    @tag :user
    test "comment activities", %{conn: conn, actor: actor} do
      community = Factory.community(actor)
      comment = %{id: comment_id} = Factory.comment(actor, community)
      MoodleNet.like_comment(actor, comment)

      assert ret =
               conn
               |> post("/api/graphql", %{query: query(2)})
               |> json_response(200)
               |> Map.fetch!("data")
               |> Map.fetch!("localActivities")

      assert %{
               "pageInfo" => %{"startCursor" => nil, "endCursor" => endCursor},
               "nodes" => [like, create]
             } = ret

      assert endCursor
      actor_id = actor.id

      assert %{
               "activityType" => "LikeComment",
               "object" => %{
                 "__typename" => "Comment",
                 "id" => ^comment_id,
                 "replies" => %{"totalCount" => 0}
               },
               "user" => %{"id" => ^actor_id}
             } = like

      assert %{
               "activityType" => "CreateComment",
               "object" => %{
                 "__typename" => "Comment",
                 "id" => ^comment_id,
                 "replies" => %{"totalCount" => 0}
               },
               "user" => %{"id" => ^actor_id}
             } = create
    end
  end
end
