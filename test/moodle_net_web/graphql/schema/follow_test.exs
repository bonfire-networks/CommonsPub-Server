defmodule MoodleNetWeb.GraphQL.FollowTest do
  use MoodleNetWeb.ConnCase

  import ActivityPub.Entity, only: [local_id: 1]
  @moduletag format: :json

  @tag :user
  test "join_community & undo", %{conn: conn, actor: actor} do
    community = Factory.community(actor)

    query = """
    {
      communities {
        id
        localId
        followed
        followersCount
        followers {
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

    assert [community_map] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("communities")

    assert community_map["id"] == community.id
    assert community_map["localId"] == local_id(community)
    assert community_map["followed"] == true
    assert community_map["followersCount"] == 1

    assert [user_map] = community_map["followers"]
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
        undoJoinCommunity(
          communityLocalId: #{local_id(community)}
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
      communities {
        id
        localId
        followed
        followersCount
        followers {
          id
        }
      }
    }
    """

    assert [community_map] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("communities")

    assert community_map["id"] == community.id
    assert community_map["localId"] == local_id(community)
    assert community_map["followed"] == false
    assert community_map["followersCount"] == 0

    assert [] = community_map["followers"]

    query = """
      mutation {
        joinCommunity(
          communityLocalId: #{local_id(community)}
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
      communities {
        id
        localId
        followed
        followersCount
        followers {
          id
        }
      }
    }
    """

    assert [community_map] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("communities")

    assert community_map["id"] == community.id
    assert community_map["localId"] == local_id(community)
    assert community_map["followed"] == true
    assert community_map["followersCount"] == 1

    actor_id = actor.id
    assert [%{"id" => ^actor_id}] = community_map["followers"]
  end

  @tag :user
  test "follow_collection & undo", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)
    collection_id = local_id(collection)

    query = """
    {
      collection(localId: #{collection_id}) {
        id
        localId
        followed
        followersCount
        followers {
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

    assert collection_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collection")

    assert collection_map["id"] == collection.id
    assert collection_map["localId"] == local_id(collection)
    assert collection_map["followed"] == true
    assert collection_map["followersCount"] == 1

    assert [user_map] = collection_map["followers"]
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
        undoFollowCollection(
          collectionLocalId: #{local_id(collection)}
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
      collection(localId: #{collection_id}) {
        id
        localId
        followed
        followersCount
        followers {
          id
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
    assert collection_map["localId"] == local_id(collection)
    assert collection_map["followed"] == false
    assert collection_map["followersCount"] == 0

    assert [] = collection_map["followers"]

    query = """
      mutation {
        followCollection(
          collectionLocalId: #{local_id(collection)}
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
      collection(localId: #{collection_id}) {
        id
        localId
        followed
        followersCount
        followers {
          id
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
    assert collection_map["localId"] == local_id(collection)
    assert collection_map["followed"] == true
    assert collection_map["followersCount"] == 1

    actor_id = actor.id
    assert [%{"id" => ^actor_id}] = collection_map["followers"]
  end
end
