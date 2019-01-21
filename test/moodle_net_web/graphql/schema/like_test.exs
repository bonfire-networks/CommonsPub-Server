defmodule MoodleNetWeb.GraphQL.LikeTest do
  use MoodleNetWeb.ConnCase

  import ActivityPub.Entity, only: [local_id: 1]
  @moduletag format: :json

  @tag :user
  test "like and unlike a comment", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)
    collection_id = local_id(collection)
    comment = Factory.comment(actor, collection)
    comment_id = local_id(comment)

    query = """
      mutation {
        undo_like_comment(
          localId: #{comment_id}
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
        like_comment(
          localId: #{comment_id}
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("like_comment")

    query = """
    {
      collection(localId: #{collection_id}) {
        comments {
          id
          localId
          likesCount
          likers {
            id
            localId
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
    """

    assert [comment_map] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collection")
             |> Map.fetch!("comments")

    assert comment_map["id"] == comment.id
    assert comment_map["localId"] == local_id(comment)
    assert comment_map["likesCount"] == 1

    assert [user_map] = comment_map["likers"]
    assert user_map["id"] == actor.id
    assert user_map["localId"] == local_id(actor)
    assert user_map["local"] == ActivityPub.Entity.local?(actor)
    assert user_map["type"] == actor.type
    assert user_map["preferredUsername"] == actor.preferred_username
    assert user_map["name"] == actor.name["und"]
    assert user_map["summary"] == actor.summary["und"]
    assert user_map["location"] == get_in(actor, [:location, Access.at(0), :content, "und"])
    assert user_map["icon"] == get_in(actor, [:icon, Access.at(0), :url, Access.at(0)])

    query = """
      mutation {
        undo_like_comment(
          localId: #{comment_id}
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("undo_like_comment")

    query = """
    {
      collection(localId: #{collection_id}) {
        comments {
          id
          localId
          likesCount
          likers {
            id
          }
        }
      }
    }
    """

    assert [comment_map] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collection")
             |> Map.fetch!("comments")

    assert comment_map["id"] == comment.id
    assert comment_map["localId"] == local_id(comment)
    assert comment_map["likesCount"] == 0

    assert [] = comment_map["likers"]

    query = """
      mutation {
        undo_like_comment(
          localId: #{comment_id}
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
  test "like and unlike a resource", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)
    collection_id = local_id(collection)
    resource = Factory.resource(actor, collection)
    resource_id = local_id(resource)

    query = """
      mutation {
        undo_like_resource(
          localId: #{resource_id}
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
        like_resource(
          localId: #{resource_id}
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("like_resource")

    query = """
    {
      resources(collectionLocalId: #{collection_id}) {
        id
        localId
        likesCount
        likers {
          id
          localId
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
    """

    assert [resource_map] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("resources")

    assert resource_map["id"] == resource.id
    assert resource_map["localId"] == local_id(resource)
    assert resource_map["likesCount"] == 1

    assert [user_map] = resource_map["likers"]
    assert user_map["id"] == actor.id
    assert user_map["localId"] == local_id(actor)
    assert user_map["local"] == ActivityPub.Entity.local?(actor)
    assert user_map["type"] == actor.type
    assert user_map["preferredUsername"] == actor.preferred_username
    assert user_map["name"] == actor.name["und"]
    assert user_map["summary"] == actor.summary["und"]
    assert user_map["location"] == get_in(actor, [:location, Access.at(0), :content, "und"])
    assert user_map["icon"] == get_in(actor, [:icon, Access.at(0), :url, Access.at(0)])

    query = """
      mutation {
        undo_like_resource(
          localId: #{resource_id}
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("undo_like_resource")

    query = """
    {
      resources(collectionLocalId: #{collection_id}) {
        id
        localId
        likesCount
        likers {
          id
        }
      }
    }
    """

    assert [resource_map] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("resources")

    assert resource_map["id"] == resource.id
    assert resource_map["localId"] == local_id(resource)
    assert resource_map["likesCount"] == 0

    assert [] = resource_map["likers"]

    query = """
      mutation {
        undo_like_resource(
          localId: #{resource_id}
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

end
