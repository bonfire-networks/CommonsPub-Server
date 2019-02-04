defmodule MoodleNetWeb.GraphQL.CommunityTest do
  use MoodleNetWeb.ConnCase

  import ActivityPub.Entity, only: [local_id: 1]
  @moduletag format: :json

  @tag :user
  test "create community", %{conn: conn} do
    query = """
      mutation {
        createCommunity(
          community: {
            name: "community_name"
            summary: "community_summary"
            content:"community_content"
            preferredUsername: "community_preferredUser"
            primaryLanguage:"community_language"
            icon:"https://imag.es/community"
          }
        ) {
          id
          localId
          name
          summary
          content
          preferredUsername
          primaryLanguage
          icon
          published
          updated
        }
      }
    """

    assert community =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("createCommunity")

    assert community["id"]
    assert community["localId"]
    assert community["published"]
    assert community["updated"]
    assert community["name"] == "community_name"
    assert community["summary"] == "community_summary"
    assert community["content"] == "community_content"
    assert community["preferredUsername"] == "community_preferredUser"
    assert community["primaryLanguage"] == "community_language"
    assert community["icon"] == "https://imag.es/community"
  end

  @tag :user
  test "collection connection", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    local_id = local_id(community)

    query = """
      {
        community(localId: #{local_id}) {
          collections {
            pageInfo {
              startCursor
              endCursor
            }
            edges {
              cursor
              node {
                id
              }
            }
            totalCount
          }
        }
      }
    """

    assert ret =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")
             |> Map.fetch!("collections")

    assert %{
             "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
             "edges" => [],
             "totalCount" => 0
           } = ret

    %{id: a_id} = Factory.collection(actor, community)
    %{id: b_id} = Factory.collection(actor, community)

    assert ret =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")
             |> Map.fetch!("collections")

    assert %{
             "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
             "edges" => edges,
             "totalCount" => 2
           } = ret

    assert [
             %{
               "cursor" => cursor_b,
               "node" => %{
                 "id" => ^b_id
               }
             },
             %{
               "cursor" => cursor_a,
               "node" => %{
                 "id" => ^a_id
               }
             }
           ] = edges

    assert cursor_a
    assert cursor_b
    assert cursor_b > cursor_a
  end

  @tag :user
  test "thread connection", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    local_id = local_id(community)

    query = """
      {
        community(localId: #{local_id}) {
          threads {
            pageInfo {
              startCursor
              endCursor
            }
            edges {
              cursor
              node {
                id
              }
            }
            totalCount
          }
        }
      }
    """

    assert ret =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")
             |> Map.fetch!("threads")

    assert %{
             "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
             "edges" => [],
             "totalCount" => 0
           } = ret

    %{id: a_id} = Factory.comment(actor, community)
    %{id: b_id} = Factory.comment(actor, community)

    assert ret =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")
             |> Map.fetch!("threads")

    assert %{
             "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
             "edges" => edges,
             "totalCount" => 2
           } = ret

    assert [
             %{
               "cursor" => cursor_b,
               "node" => %{
                 "id" => ^b_id
               }
             },
             %{
               "cursor" => cursor_a,
               "node" => %{
                 "id" => ^a_id
               }
             }
           ] = edges

    assert cursor_a
    assert cursor_b
    assert cursor_b > cursor_a
  end

  @tag :user
  test "members", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    local_id = local_id(community)

    query = """
    {
      community(local_id: #{local_id}) {
        members {
          pageInfo {
            startCursor
            endCursor
          }
          edges {
            cursor
            node {
              id
              localId
              name
            }
          }
          totalCount
        }
      }
    }
    """

    assert members =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")
             |> Map.fetch!("members")

    assert %{
             "pageInfo" => %{
               "startCursor" => nil,
               "endCursor" => nil
             },
             "edges" => [
               %{
                 "cursor" => cursor,
                 "node" => actor_map
               }
             ],
             "totalCount" => 1
           } = members
  end

  @tag :user
  test "join_community & undo", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    community_local_id = local_id(community)

    query = """
    {
      community(localId: #{community_local_id}) {
        id
        localId
        followed
        members {
          totalCount
          edges {
            node {
              id
            }
          }
        }
      }
    }
    """

    assert community_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")

    assert community_map["id"] == community.id
    assert community_map["localId"] == community_local_id
    assert community_map["followed"] == true

    assert %{
             "totalCount" => 1,
             "edges" => [
               %{
                 "node" => user_map
               }
             ]
           } = community_map["members"]

    assert user_map["id"] == actor.id

    query = """
      mutation {
        undoJoinCommunity(
          communityLocalId: #{community_local_id}
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("undoJoinCommunity")

    assert [
             %{
               "code" => "not_found",
               "message" => "Activity not found"
             }
           ] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("errors")

    query = """
    {
      community(localId: #{community_local_id}) {
        id
        localId
        followed
        members {
          totalCount
          edges {
            node {
              id
            }
          }
        }
      }
    }
    """

    assert community_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")

    assert community_map["id"] == community.id
    assert community_map["localId"] == community_local_id
    assert community_map["followed"] == false

    assert %{
             "totalCount" => 0,
             "edges" => []
           } = community_map["members"]


    query = """
      mutation {
        joinCommunity(
          communityLocalId: #{community_local_id}
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("joinCommunity")

    query = """
    {
      community(localId: #{community_local_id}) {
        id
        localId
        followed
        members {
          totalCount
          edges {
            node {
              id
            }
          }
        }
      }
    }
    """

    assert community_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")

    assert community_map["id"] == community.id
    assert community_map["localId"] == community_local_id
    assert community_map["followed"] == true

    assert %{
             "totalCount" => 1,
             "edges" => [
               %{
                 "node" => user_map
               }
             ]
           } = community_map["members"]

    assert user_map["id"] == actor.id
  end

  @tag :user
  test "delete a community", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)
    resource = Factory.resource(actor, collection)
    com_comment = Factory.comment(actor, community)
    col_comment = Factory.comment(actor, collection)
    reply = Factory.reply(actor, com_comment)

    query = """
    mutation {
      deleteCommunity(localId: #{local_id(community)})
    }
    """

    assert true ==
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("deleteCommunity")

    assert nil == ActivityPub.SQL.Query.get_by_id(community.id)
    assert nil == ActivityPub.SQL.Query.get_by_id(collection.id)
    assert nil == ActivityPub.SQL.Query.get_by_id(resource.id)
    assert nil == ActivityPub.SQL.Query.get_by_id(com_comment.id)
    assert nil == ActivityPub.SQL.Query.get_by_id(col_comment.id)
    assert nil == ActivityPub.SQL.Query.get_by_id(reply.id)
  end

  @tag :user
  test "update community", %{conn: conn, actor: actor} do
    community = Factory.community(actor)

    query = """
      mutation {
        updateCommunity(
          community_local_id: #{local_id(community)}
          community: {
            name: "community_name"
            summary: "community_summary"
            content:"community_content"
            preferredUsername: "community_preferredUser"
            primaryLanguage:"community_language"
            icon:"https://imag.es/community"
          }
        ) {
          id
          localId
          name
          summary
          content
          preferredUsername
          primaryLanguage
          icon
          published
          updated
        }
      }
    """

    assert ret_community =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("updateCommunity")

    assert ret_community["id"] == community.id
    assert ret_community["localId"]
    assert ret_community["published"]
    assert ret_community["updated"]
    assert ret_community["name"] == "community_name"
    assert ret_community["summary"] == "community_summary"
    assert ret_community["content"] == "community_content"
    assert ret_community["preferredUsername"] == "community_preferredUser"
    assert ret_community["primaryLanguage"] == "community_language"
    assert ret_community["icon"] == "https://imag.es/community"

    query = """
    {
      community(local_id: #{local_id(community)}) {
        id
        localId
        name
        summary
        content
        preferredUsername
        primaryLanguage
        icon
        published
        updated
      }
    }
    """

    assert ret_community_2 =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")

    assert ret_community == ret_community_2
  end

end
