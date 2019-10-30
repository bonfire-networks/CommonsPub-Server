# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.ResourceTest do
  use MoodleNetWeb.ConnCase#, async: true

  alias MoodleNet.Resources
  import MoodleNet.MediaProxy.URLBuilder, only: [encode: 1]
  import ActivityPub.Entity, only: [local_id: 1]

  @moduletag format: :json
  @moduletag :skip

  @tag :user
  test "create", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)

    query = """
    mutation {
      createResource(
        collectionLocalId: #{local_id(collection)},
        resource: {
          name: "resource_name"
          summary: "resource_summary"
          content:"resource_content"
          url: "resource_url"
          primaryLanguage: "resource_language"
          icon: "https://imag.es/resource"
          sameAs: "same_as",
          inLanguage: ["language"],
          publicAccess: true,
          isAccesibleForFree: true,
          license: "license",
          learningResourceType: "learning_resource_type",
          educationalUse: ["educational_use"],
          timeRequired: 60,
          typicalAgeRange: "typical_age_range"
        }
      ) {
        id
        localId
        name
        summary
        content
        url
        primaryLanguage
        icon
        published
        updated
        sameAs
        inLanguage
        publicAccess
        isAccesibleForFree
        license
        learningResourceType
        educationalUse
        timeRequired
        typicalAgeRange
        creator {
          id
          localId
          joinedCommunities { totalCount }
        }
        collection {
          id
          localId
          name
        }
      }
    }
    """

    assert resource =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("createResource")

    assert resource["id"]
    assert resource["localId"]
    assert resource["published"]
    assert resource["updated"]
    assert resource["name"] == "resource_name"
    assert resource["summary"] == "resource_summary"
    assert resource["content"] == "resource_content"
    assert resource["url"] == "resource_url"
    assert resource["primaryLanguage"] == "resource_language"
    assert resource["icon"] == encode("https://imag.es/resource")
    assert resource["sameAs"] == "same_as"
    assert resource["inLanguage"] == ["language"]
    assert resource["publicAccess"] == true
    assert resource["isAccesibleForFree"] == true
    assert resource["license"] == "license"
    assert resource["learningResourceType"] == "learning_resource_type"
    assert resource["educationalUse"] == ["educational_use"]
    assert resource["timeRequired"] == 60
    assert resource["typicalAgeRange"] == "typical_age_range"

    assert resource["creator"] == %{
      "id" => actor.id,
      "localId" => local_id(actor),
      "joinedCommunities" => %{"totalCount" => 1}
    }

    assert resource["collection"] == %{
      "id" => collection.id,
      "localId" => local_id(collection),
      "name" => collection.name["und"]
    }
  end

  @tag :user
  test "copy a resource", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)
    resource = Factory.resource(actor, collection)

    query = """
    mutation {
      copyResource(
        resourceLocalId: #{local_id(resource)}
        collectionLocalId: #{local_id(collection)}
      ) {
        id
        localId
        name
        summary
        content
        url
        primaryLanguage
        icon
        published
        updated
        sameAs
        inLanguage
        publicAccess
        isAccesibleForFree
        license
        learningResourceType
        educationalUse
        timeRequired
        typicalAgeRange
      }
    }
    """

    assert copy_resource =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("copyResource")

    query = """
    {
      resource(local_id: #{local_id(resource)}) {
        id
        localId
        name
        summary
        content
        url
        primaryLanguage
        icon
        published
        updated
        sameAs
        inLanguage
        publicAccess
        isAccesibleForFree
        license
        learningResourceType
        educationalUse
        timeRequired
        typicalAgeRange
      }
    }
    """

    assert ret_resource =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("resource")

    assert ret_resource["id"] != copy_resource["id"]
    assert ret_resource["localId"] != copy_resource["localId"]
    assert ret_resource["name"] == copy_resource["name"]
    assert ret_resource["summary"] == copy_resource["summary"]
    assert ret_resource["content"] == copy_resource["content"]
    assert ret_resource["url"] == copy_resource["url"]
    assert ret_resource["primaryLanguage"] == copy_resource["primaryLanguage"]
    assert ret_resource["icon"] == copy_resource["icon"]
    assert ret_resource["sameAs"] == copy_resource["sameAs"]
    assert ret_resource["inLanguage"] == copy_resource["inLanguage"]
    assert ret_resource["publicAccess"] == copy_resource["publicAccess"]
    assert ret_resource["isAccesibleForFree"] == copy_resource["isAccesibleForFree"]
    assert ret_resource["license"] == copy_resource["license"]
    assert ret_resource["learningResourceType"] == copy_resource["learningResourceType"]
    assert ret_resource["educationalUse"] == copy_resource["educationalUse"]
    assert ret_resource["timeRequired"] == copy_resource["timeRequired"]
    assert ret_resource["typicalAgeRange"] == copy_resource["typicalAgeRange"]
  end

  @tag :user
  test "like and unlike", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)
    resource = Factory.resource(actor, collection)
    resource_id = local_id(resource)

    query = """
      mutation {
        undoLikeResource(
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
        likeResource(
          localId: #{resource_id}
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("likeResource")

    query = """
    {
      resource(localId: #{resource_id}) {
        id
        localId
        likers {
          totalCount
          edges {
            node {
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
    }
    """

    assert resource_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("resource")

    assert resource_map["id"] == resource.id
    assert resource_map["localId"] == local_id(resource)
    assert %{
      "totalCount" => 1,
      "edges" => [%{"node" => user_map}]
    } = resource_map["likers"]

    assert user_map["id"] == actor.id
    assert user_map["localId"] == local_id(actor)
    assert user_map["local"] == ActivityPub.Entity.local?(actor)
    assert user_map["type"] == actor.type
    assert user_map["preferredUsername"] == actor.preferred_username
    assert user_map["name"] == actor.name["und"]
    assert user_map["summary"] == actor.summary["und"]
    assert user_map["location"] == get_in(actor, [:location, Access.at(0), :content, "und"])
    assert user_map["icon"] == encode(get_in(actor, [:icon, Access.at(0), :url, Access.at(0)]))

    query = """
      mutation {
        undoLikeResource(
          localId: #{resource_id}
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("undoLikeResource")

    query = """
    {
      resource(localId: #{resource_id}) {
        id
        localId
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

    assert resource_map =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("resource")

    assert resource_map["id"] == resource.id
    assert resource_map["localId"] == local_id(resource)
    assert %{
      "totalCount" => 0,
      "edges" => []
    } = resource_map["likers"]

    query = """
      mutation {
        undoLikeResource(
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

  @tag :user
  test "flag and unflag", %{conn: conn, actor: actor} do
    actor_id = local_id(actor)
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)
    resource = Factory.resource(actor, collection)
    resource_id = local_id(resource)
    reason = "Terrible joke"

    assert [] == Resources.all_flags(actor)

    query = """
      mutation {
        undoFlagResource(
          localId: #{resource_id}
        )
      }
    """

    assert [
             %{
               "code" => "not_found",
               # "message" => "Activity not found"
             }
           ] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("errors")

    query = """
      mutation {
        flagResource(
          localId: #{resource_id}
          reason: "#{reason}"
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("flagResource")

    assert [flag] = Resources.all_flags(actor)
    assert flag.flagged_object_id == resource_id
    assert flag.flagging_object_id == actor_id
    assert flag.reason == reason
    assert flag.open == true

    query = """
      mutation {
        undoFlagResource(
          localId: #{resource_id}
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("undoFlagResource")

    assert [] == Resources.all_flags(actor)

    query = """
      mutation {
        undoFlagResource(
          localId: #{resource_id}
        )
      }
    """

    assert [
             %{
               "code" => "not_found",
               # "message" => "Activity not found"
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
    res = Factory.resource(actor, coll)
    local_id = local_id(res)

    query = """
      {
        resource(localId: #{local_id}) {
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
             |> Map.fetch!("resource")
             |> Map.fetch!("likers")

    assert %{
      "pageInfo" => %{ "startCursor" => nil, "endCursor" => nil},
      "edges" => [],
      "totalCount" => 0
    } = ret

    %{id: other_actor_id} = other_actor = Factory.actor()
    {:ok, _} = MoodleNet.join_community(other_actor, comm)
    {:ok, _} = MoodleNet.like_resource(other_actor, res)

    {:ok, _} = MoodleNet.like_resource(actor, res)

    assert ret =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("resource")
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
  test "delete a resource", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)
    resource = Factory.resource(actor, collection)

    query = """
    mutation {
      deleteResource(local_id: #{local_id(resource)})
    }
    """

    assert true ==
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("deleteResource")

    assert ActivityPub.SQL.Query.get_by_id(community.id)
    assert ActivityPub.SQL.Query.get_by_id(collection.id)
    assert nil == ActivityPub.SQL.Query.get_by_id(resource.id)
  end

  @tag :user
  test "update resource", %{conn: conn, actor: actor} do
    community = Factory.community(actor)
    collection = Factory.collection(actor, community)
    resource = Factory.resource(actor, collection)

    query = """
    mutation {
      updateResource(
        resourceLocalId: #{local_id(resource)},
        resource: {
          name: "resource_name"
          summary: "resource_summary"
          content:"resource_content"
          url: "resource_url"
          primaryLanguage: "resource_language"
          icon: "https://imag.es/resource"
          sameAs: "same_as",
          inLanguage: ["language"],
          publicAccess: true,
          isAccesibleForFree: true,
          license: "license",
          learningResourceType: "learning_resource_type",
          educationalUse: ["educational_use"],
          timeRequired: 60,
          typicalAgeRange: "typical_age_range"
        }
      ) {
        id
        localId
        name
        summary
        content
        url
        primaryLanguage
        icon
        published
        updated
        sameAs
        inLanguage
        publicAccess
        isAccesibleForFree
        license
        learningResourceType
        educationalUse
        timeRequired
        typicalAgeRange
      }
    }
    """

    assert ret_resource =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("updateResource")

    assert ret_resource["id"]
    assert ret_resource["localId"]
    assert ret_resource["published"]
    assert ret_resource["updated"]
    assert ret_resource["name"] == "resource_name"
    assert ret_resource["summary"] == "resource_summary"
    assert ret_resource["content"] == "resource_content"
    assert ret_resource["url"] == "resource_url"
    assert ret_resource["primaryLanguage"] == "resource_language"
    assert ret_resource["icon"] == encode("https://imag.es/resource")
    assert ret_resource["sameAs"] == "same_as"
    assert ret_resource["inLanguage"] == ["language"]
    assert ret_resource["publicAccess"] == true
    assert ret_resource["isAccesibleForFree"] == true
    assert ret_resource["license"] == "license"
    assert ret_resource["learningResourceType"] == "learning_resource_type"
    assert ret_resource["educationalUse"] == ["educational_use"]
    assert ret_resource["timeRequired"] == 60
    assert ret_resource["typicalAgeRange"] == "typical_age_range"

    query = """
    {
      resource(localId: #{local_id(resource)}) { id
        localId
        name
        summary
        content
        url
        primaryLanguage
        icon
        published
        updated
        sameAs
        inLanguage
        publicAccess
        isAccesibleForFree
        license
        learningResourceType
        educationalUse
        timeRequired
        typicalAgeRange
      }
    }
    """

    assert ret_resource_2 =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("resource")

    assert ret_resource == ret_resource_2
  end
end
