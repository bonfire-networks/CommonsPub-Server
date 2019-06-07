# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.CommentTest do
  # , async: true
  use MoodleNetWeb.ConnCase

  @moduletag format: :json

  @tag :user
  test "create thread", %{conn: conn, actor: actor} do
    community = Factory.community(actor)

    query = """
    mutation {
      createThread(
        contextId: "#{community.id}",
        comment: {
          content:"comment_1"
        }
      ) {
          id
          local
          type
          content
          published
          updated
          author {
            id
            preferredUsername
          }
      }
    }
    """

    assert comment =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("createThread")

    assert comment["id"]
    assert comment["local"] == true
    assert comment["type"] == ["Object", "Note"]
    assert comment["updated"]
    assert comment["published"]
    assert comment["content"] == "comment_1"

    assert comment["author"]["id"] == actor.id
    assert comment["author"]["preferredUsername"] == actor.preferred_username

    collection = Factory.collection(actor, community)
    query = """
    mutation {
      createThread(
        contextId: "#{collection.id}",
        comment: {
          content:"comment_2"
        }
      ) {
          id
          local
          type
          content
          published
          updated
          author {
            id
            preferredUsername
          }
      }
    }
    """

    assert comment =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("createThread")

    assert comment["id"]
    assert comment["local"] == true
    assert comment["type"] == ["Object", "Note"]
    assert comment["updated"]
    assert comment["published"]
    assert comment["content"] == "comment_2"

    assert comment["author"]["id"] == actor.id
    assert comment["author"]["preferredUsername"] == actor.preferred_username
  end

  @tag :user
  test "comment context", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)
    resource = Factory.resource(actor, collection)
    %{id: comm_comment_id} = comm_comment = Factory.comment(actor, community)
    %{id: coll_comment_id} = coll_comment = Factory.comment(actor, collection)

    query = """
    {
      comment(id: "#{comm_comment.id}") {
        id
        context {
          __typename
          ... on Community {
            id
            name
            collections {
              edges {
                node {
                  id
                }
              }
            }
          }
          ... on Collection {
            id
            name
            resources {
              edges {
                node {
                  id
                }
              }
            }
          }
        }
      }
    }
    """

    assert comm_comment_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("comment")

    assert %{
             "id" => ^comm_comment_id,
             "context" => community_map
           } = comm_comment_map

    assert community_map["__typename"] == "Community"
    assert community_map["id"] == community.id
    assert community_map["name"] == community.name["und"]
    assert [%{"node" => %{"id" => collection_id}}] = community_map["collections"]["edges"]
    assert collection_id == collection.id

    query = """
    {
      comment(id: "#{coll_comment.id}") {
        id
        context {
          __typename
          ... on Community {
            id
            name
            collections {
              edges {
                node {
                  id
                }
              }
            }
          }
          ... on Collection {
            id
            name
            resources {
              edges {
                node {
                  id
                }
              }
            }
          }
        }
      }
    }
    """

    assert coll_comment_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("comment")

    assert %{
             "id" => ^coll_comment_id,
             "context" => collection_map
           } = coll_comment_map

    assert collection_map["__typename"] == "Collection"
    assert collection_map["id"] == collection.id
    assert collection_map["name"] == collection.name["und"]
    assert [%{"node" => %{"id" => resource_id}}] = collection_map["resources"]["edges"]
    assert resource_id == resource.id
  end

  @tag :user
  test "create reply", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    comment = Factory.comment(actor, community)

    query = """
    mutation {
      createReply(
        inReplyToId: "#{comment.id}",
        comment: {
          content:"comment_2"
        }
      ) {
          id
          local
          type
          content
          published
          updated
          author {
            id
            preferredUsername
          }
      }
    }
    """

    assert comment =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("createReply")

    assert comment["id"]
    assert comment["local"] == true
    assert comment["type"] == ["Object", "Note"]
    assert comment["updated"]
    assert comment["published"]
    assert comment["content"] == "comment_2"

    assert comment["author"]["id"] == actor.id
    assert comment["author"]["preferredUsername"] == actor.preferred_username
  end

  @tag :user
  test "in reply to assoc", %{conn: conn, actor: actor} do
    comm = Factory.community(actor)
    coll = Factory.collection(actor, comm)
    comment = Factory.comment(actor, coll)

    query = """
      {
        comment(id: "#{comment.id}") {
          inReplyTo {
            id
            content
            author {
              id
            }
          }
        }
      }
    """

    assert ret =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("comment")

    assert %{"inReplyTo" => nil} = ret

    reply = Factory.reply(actor, comment)

    query = """
      {
        comment(id: "#{reply.id}") {
          inReplyTo {
            id
            content
            author {
              id
            }
          }
        }
      }
    """

    assert ret =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("comment")

    assert %{
             "id" => comment.id,
             "content" => comment.content["und"],
             "author" => %{
               "id" => actor.id
             }
           } == ret["inReplyTo"]
  end

  @tag :user
  test "reply list", %{conn: conn, actor: actor} do
    comm = Factory.community(actor)
    coll = Factory.collection(actor, comm)
    comment = Factory.comment(actor, coll)

    query = """
      {
        comment(id: "#{comment.id}") {
          replies {
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
             |> Map.fetch!("comment")
             |> Map.fetch!("replies")

    assert %{
             "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
             "edges" => [],
             "totalCount" => 0
           } = ret

    %{id: a_id} = Factory.reply(actor, comment)
    %{id: b_id} = Factory.reply(actor, comment)

    assert ret =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("comment")
             |> Map.fetch!("replies")

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
  test "like and unlike a comment", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)
    comment = Factory.comment(actor, collection)

    query = """
      mutation {
        undoLikeComment(
          id: "#{comment.id}"
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
        likeComment(
          id: "#{comment.id}"
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("likeComment")

    query = """
    {
      comment(id: "#{comment.id}") {
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

    assert comment_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("comment")

    assert comment_map["id"] == comment.id

    assert %{
             "totalCount" => 1,
             "edges" => [%{"node" => user_map}]
           } = comment_map["likers"]

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
        undoLikeComment(
          id: "#{comment.id}"
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("undoLikeComment")

    query = """
    {
      comment(id: "#{comment.id}") {
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

    assert comment_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("comment")

    assert comment_map["id"] == comment.id

    assert %{
             "totalCount" => 0,
             "edges" => []
           } = comment_map["likers"]

    query = """
      mutation {
        undoLikeComment(
          id: "#{comment.id}"
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
    comment = Factory.comment(actor, coll)

    query = """
      {
        comment(id: "#{comment.id}") {
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
             |> Map.fetch!("comment")
             |> Map.fetch!("likers")

    assert %{
             "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
             "edges" => [],
             "totalCount" => 0
           } = ret

    %{id: other_actor_id} = other_actor = Factory.actor()
    {:ok, _} = MoodleNet.join_community(other_actor, comm)
    {:ok, _} = MoodleNet.like_comment(other_actor, comment)

    {:ok, _} = MoodleNet.like_comment(actor, comment)

    assert ret =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("comment")
             |> Map.fetch!("likers")

    assert %{
             "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
             "edges" => edges,
             "totalCount" => 2
           } = ret

    assert [
             %{
               "cursor" => cursor_b,
               "node" => %{
                 "id" => ^actor_id
               }
             },
             %{
               "cursor" => cursor_a,
               "node" => %{
                 "id" => ^other_actor_id
               }
             }
           ] = edges

    assert cursor_a
    assert cursor_b
    assert cursor_b > cursor_a
  end

  @tag :user
  test "delete comment", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    comment = Factory.comment(actor, community)
    other_actor = Factory.actor()
    MoodleNet.join_community(other_actor, community)
    other_comment = Factory.comment(other_actor, community)

    query = """
    mutation {
      deleteComment(id: "#{comment.id}")
    }
    """

    assert true ==
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("deleteComment")

    query = """
    {
      comment(id: "#{comment.id}") {
        id
      }
    }
    """

    assert nil ==
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("comment")

    query = """
    mutation {
      deleteComment(id: "#{other_comment.id}")
    }
    """

    assert [
             %{
               "code" => "forbidden",
               "message" => "You are not authorized to perform this action"
             }
           ] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("errors")

    query = """
    {
      comment(id: "#{other_comment.id}") {
        id
      }
    }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("comment")
  end
end
