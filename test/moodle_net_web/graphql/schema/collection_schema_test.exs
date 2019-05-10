# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.CollectionTest do
  use MoodleNetWeb.ConnCase#, async: true

  @moduletag format: :json

  @tag :user
  test "list", %{conn: conn, actor: actor} do
    query = """
      {
        collections {
          pageInfo {
            startCursor
            endCursor
          }
          nodes {
            id
            resources {
              totalCount
            }
          }
          totalCount
        }
      }
    """

    assert ret =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collections")

    assert %{
             "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
             "nodes" => [],
             "totalCount" => 0
           } = ret

    comm = Factory.community(actor)
    %{id: a_id} = Factory.collection(actor, comm)
    %{id: b_id} = Factory.collection(actor, comm)

    assert ret =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collections")

    assert %{
             "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
             "nodes" => nodes,
             "totalCount" => 2
           } = ret

    assert [%{"id" => ^b_id}, %{"id" => ^a_id}] = nodes
  end

  @tag :user
  test "create", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    query = """
    mutation {
      createCollection(
        communityId: "#{community.id}",
        collection: {
          name: "collection_name"
          summary: "collection_summary"
          content:"collection_content"
          preferredUsername: "collection_preferredUser"
          primaryLanguage:"collection_language"
          icon:"https://imag.es/collection"
        }
      ) {
        id
        name
        summary
        content
        preferredUsername
        primaryLanguage
        icon
        published
        updated
        creator {
          id
          joinedCommunities { totalCount }
        }
        community {
          id
          name
        }
      }
    }
    """

    assert collection =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("createCollection")

    assert collection["id"]
    assert collection["published"]
    assert collection["updated"]
    assert collection["name"] == "collection_name"
    assert collection["summary"] == "collection_summary"
    assert collection["content"] == "collection_content"
    assert collection["preferredUsername"] == "collection_preferredUser"
    assert collection["primaryLanguage"] == "collection_language"
    assert collection["icon"] == "https://imag.es/collection"
    assert collection["community"] == %{
      "id" => community.id,
      "name" => community.name["und"]
    }
    assert collection["creator"] == %{
      "id" => actor.id,
      "joinedCommunities" => %{"totalCount" => 1}
    }
  end

  @tag :user
  test "follower list", %{conn: conn, actor: actor} do
    %{id: other_actor_id} = other_actor = Factory.actor()
    comm = Factory.community(actor)
    coll = Factory.collection(actor, comm)
    actor_id = actor.id

    query = """
      {
        collection(id: "#{coll.id}") {
          followers {
            pageInfo {
              startCursor
              endCursor
            }
            edges {
              cursor
              node {
                id
                preferredUsername
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
             |> Map.fetch!("collection")
             |> Map.fetch!("followers")

    assert %{
      "pageInfo" => %{ "startCursor" => nil, "endCursor" => nil},
      "edges" => edges,
      "totalCount" => 1
    } = ret

    assert [
      %{
        "cursor" => _,
        "node" => %{
          "id" => ^actor_id,
        }
      }
    ] = edges

    MoodleNet.follow_collection(other_actor, coll)

    assert ret =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collection")
             |> Map.fetch!("followers")

    assert %{
      "pageInfo" => %{ "startCursor" => nil, "endCursor" => nil},
      "edges" => edges,
      "totalCount" => 2
    } = ret

    assert [
      %{
        "cursor" => cursor_b,
        "node" => %{
          "id" => ^other_actor_id,
        }
      },
      %{
        "cursor" => cursor_a,
        "node" => %{
          "id" => ^actor_id,
        }
      }
    ] = edges

    assert cursor_a
    assert cursor_b
    assert cursor_b > cursor_a
  end

  @tag :user
  test "follow_collection & undo", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)

    query = """
    {
      collection(id: "#{collection.id}") {
        id
        followed
        followers {
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

    assert collection_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collection")

    assert collection_map["id"] == collection.id
    assert collection_map["followed"] == true

    assert %{
             "totalCount" => 1,
             "edges" => [
               %{
                 "node" => user_map
               }
             ]
           } = collection_map["followers"]

    assert user_map["id"] == actor.id

    query = """
      mutation {
        undoFollowCollection(
          collectionId: "#{collection.id}"
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("undoFollowCollection")

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
      collection(id: "#{collection.id}") {
        id
        followed
        followers {
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

    assert collection_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collection")

    assert collection_map["id"] == collection.id
    assert collection_map["followed"] == false

    assert %{
             "totalCount" => 0,
             "edges" => []
           } = collection_map["followers"]

    query = """
      mutation {
        followCollection(
          collectionId: "#{collection.id}"
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("followCollection")

    query = """
    {
      collection(id: "#{collection.id}") {
        id
        followed
        followers {
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

    assert collection_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collection")

    assert collection_map["id"] == collection.id
    assert collection_map["followed"] == true

    assert %{
             "totalCount" => 1,
             "edges" => [
               %{
                 "node" => user_map
               }
             ]
           } = collection_map["followers"]

    assert user_map["id"] == actor.id
  end
  @tag :user
  test "resource list", %{conn: conn, actor: actor} do
    comm = Factory.community(actor)
    coll = Factory.collection(actor, comm)

    query = """
      {
        collection(id: "#{coll.id}") {
          resources {
            pageInfo {
              startCursor
              endCursor
            }
            edges {
              cursor
              node {
                id
                license
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
             |> Map.fetch!("collection")
             |> Map.fetch!("resources")

    assert %{
      "pageInfo" => %{ "startCursor" => nil, "endCursor" => nil},
      "edges" => [],
      "totalCount" => 0
    } = ret

    %{id: a_id} = Factory.resource(actor, coll)
    %{id: b_id} = Factory.resource(actor, coll)

    assert ret =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collection")
             |> Map.fetch!("resources")

    assert %{
      "pageInfo" => %{ "startCursor" => nil, "endCursor" => nil},
      "edges" => edges,
      "totalCount" => 2
    } = ret

    assert [
      %{
        "cursor" => cursor_b,
        "node" => %{
          "id" => ^b_id,
        }
      },
      %{
        "cursor" => cursor_a,
        "node" => %{
          "id" => ^a_id,
        }
      }
    ] = edges

    assert cursor_a
    assert cursor_b
    assert cursor_b > cursor_a
  end

  @tag :user
  test "thread list", %{conn: conn, actor: actor} do
    comm = Factory.community(actor)
    coll = Factory.collection(actor, comm)

    query = """
      {
        collection(id: "#{coll.id}") {
          threads {
            pageInfo {
              startCursor
              endCursor
            }
            edges {
              cursor
              node {
                id
                author {
                  id
                }
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
             |> Map.fetch!("collection")
             |> Map.fetch!("threads")

    assert %{
      "pageInfo" => %{ "startCursor" => nil, "endCursor" => nil},
      "edges" => [],
      "totalCount" => 0
    } = ret

    %{id: a_id} = Factory.comment(actor, coll)
    %{id: b_id} = Factory.comment(actor, coll)

    assert ret =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collection")
             |> Map.fetch!("threads")

    assert %{
      "pageInfo" => %{ "startCursor" => nil, "endCursor" => nil},
      "edges" => edges,
      "totalCount" => 2
    } = ret

    assert [
      %{
        "cursor" => cursor_b,
        "node" => %{
          "id" => ^b_id,
        }
      },
      %{
        "cursor" => cursor_a,
        "node" => %{
          "id" => ^a_id,
        }
      }
    ] = edges

    assert cursor_a
    assert cursor_b
    assert cursor_b > cursor_a
  end

  @tag :user
  test "like and unlike", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)

    query = """
      mutation {
        undoLikeCollection(
          id: "#{collection.id}"
        )
      }
    """

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
      mutation {
        likeCollection(
          id: "#{collection.id}"
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("likeCollection")

    query = """
    {
      collection(id: "#{collection.id}") {
        id
        likers {
          totalCount
          edges {
            node {
              id
              local
              type
              preferredUsername
              name
              summary
              location
              icon
            }
          }
        }
      }
    }
    """

    assert collection_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collection")

    assert collection_map["id"] == collection.id
    assert %{
      "totalCount" => 1,
      "edges" => [%{"node" => user_map}]
    } = collection_map["likers"]

    assert user_map["id"] == actor.id
    assert user_map["local"] == ActivityPub.Entity.local?(actor)
    assert user_map["type"] == actor.type
    assert user_map["preferredUsername"] == actor.preferred_username
    assert user_map["name"] == actor.name["und"]
    assert user_map["summary"] == actor.summary["und"]
    assert user_map["location"] == get_in(actor, [:location, Access.at(0), :content, "und"])
    assert user_map["icon"] == get_in(actor, [:icon, Access.at(0), :url, Access.at(0)])

    query = """
      mutation {
        undoLikeCollection(
          id: "#{collection.id}"
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("undoLikeCollection")

    query = """
    {
      collection(id: "#{collection.id}") {
        id
        likers {
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

    assert collection_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collection")

    assert collection_map["id"] == collection.id
    assert %{
      "totalCount" => 0,
      "edges" => []
    } = collection_map["likers"]

    query = """
      mutation {
        undoLikeCollection(
          id: "#{collection.id}"
        )
      }
    """

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
  end

  @tag :user
  test "liker list", %{conn: conn, actor: actor} do
    %{id: actor_id} = actor
    comm = Factory.community(actor)
    coll = Factory.collection(actor, comm)

    query = """
      {
        collection(id: "#{coll.id}") {
          likers {
            pageInfo {
              startCursor
              endCursor
            }
            edges {
              cursor
              node {
                id
                joinedCommunities {
                  totalCount
                }
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
             |> Map.fetch!("collection")
             |> Map.fetch!("likers")

    assert %{
      "pageInfo" => %{ "startCursor" => nil, "endCursor" => nil},
      "edges" => [],
      "totalCount" => 0
    } = ret

    %{id: other_actor_id} = other_actor = Factory.actor()
    {:ok, _} = MoodleNet.join_community(other_actor, comm)
    {:ok, _} = MoodleNet.like_collection(other_actor, coll)

    {:ok, _} = MoodleNet.like_collection(actor, coll)

    assert ret =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collection")
             |> Map.fetch!("likers")

    assert %{
      "pageInfo" => %{ "startCursor" => nil, "endCursor" => nil},
      "edges" => edges,
      "totalCount" => 2
    } = ret

    assert [
      %{
        "cursor" => cursor_b,
        "node" => %{
          "id" => ^actor_id,
        }
      },
      %{
        "cursor" => cursor_a,
        "node" => %{
          "id" => ^other_actor_id,
        }
      }
    ] = edges

    assert cursor_a
    assert cursor_b
    assert cursor_b > cursor_a
  end

  @tag :user
  test "delete a collection", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)
    resource = Factory.resource(actor, collection)
    comment = Factory.comment(actor, collection)
    reply = Factory.reply(actor, comment)

    query = """
    mutation {
      deleteCollection(id: "#{collection.id}")
    }
    """

    assert true ==
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("deleteCollection")

    assert ActivityPub.SQL.Query.get_by_id(community.id)
    assert nil == ActivityPub.SQL.Query.get_by_id(collection.id)
    assert nil == ActivityPub.SQL.Query.get_by_id(resource.id)
    assert nil == ActivityPub.SQL.Query.get_by_id(comment.id)
    assert nil == ActivityPub.SQL.Query.get_by_id(reply.id)
  end

  @tag :user
  test "update collection", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)

    query = """
    mutation {
      updateCollection(
        collectionId: "#{collection.id}",
        collection: {
          name: "collection_name"
          summary: "collection_summary"
          content:"collection_content"
          preferredUsername: "collection_preferredUser"
          primaryLanguage:"collection_language"
          icon:"https://imag.es/collection"
        }
      ) {
        id
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

    assert ret_collection =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("updateCollection")

    assert ret_collection["id"] == collection.id
    assert ret_collection["published"]
    assert ret_collection["updated"]
    assert ret_collection["name"] == "collection_name"
    assert ret_collection["summary"] == "collection_summary"
    assert ret_collection["content"] == "collection_content"
    assert ret_collection["preferredUsername"] == "collection_preferredUser"
    assert ret_collection["primaryLanguage"] == "collection_language"
    assert ret_collection["icon"] == "https://imag.es/collection"

    query = """
    {
      collection(id: "#{collection.id}") {
        id
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

    assert ret_collection_2 =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collection")

    assert ret_collection == ret_collection_2
  end

  @tag :user
  test "inbox connection", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    MoodleNet.update_community(actor, community, %{name: "Name"})

    collection = Factory.collection(actor, community)
    MoodleNet.update_collection(actor, collection, %{name: "Name"})
    MoodleNet.like_collection(actor, collection)

    resource = Factory.resource(actor, collection)
    MoodleNet.update_resource(actor, resource, %{name: "Name"})
    MoodleNet.like_resource(actor, resource)

    comment = Factory.comment(actor, collection)
    reply = Factory.reply(actor, comment)
    MoodleNet.like_comment(actor, comment)
    MoodleNet.like_comment(actor, reply)

    query = """
      {
        collection(id: "#{collection.id}") {
          inbox {
            pageInfo {
              startCursor
              endCursor
            }
            edges {
              cursor
              node {
                id
                activity_type
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
             |> Map.fetch!("collection")
             |> Map.fetch!("inbox")

    assert %{
             "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
             "edges" => edges,
             "totalCount" => 10
           } = ret

    assert [
             %{
               "node" => %{
                 "activity_type" => "LikeComment"
               }
             },
             %{
               "node" => %{
                 "activity_type" => "LikeComment"
               }
             },
             %{
               "node" => %{
                 "activity_type" => "CreateComment"
               }
             },
             %{
               "node" => %{
                 "activity_type" => "CreateComment"
               }
             },
             %{
               "node" => %{
                 "activity_type" => "LikeResource"
               }
             },
             %{
               "node" => %{
                 "activity_type" => "UpdateResource"
               }
             },
             %{
               "node" => %{
                 "activity_type" => "CreateResource"
               }
             },
             %{
               "node" => %{
                 "activity_type" => "LikeCollection"
               }
             },
             %{
               "node" => %{
                 "activity_type" => "UpdateCollection"
               }
             },
             %{
               "node" => %{
                 "activity_type" => "FollowCollection"
               }
             }
           ] = edges
  end
end
