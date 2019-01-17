defmodule MoodleNetWeb.GraphQL.MoodleNetSchemaTest do
  # , async: true
  use MoodleNetWeb.ConnCase

  alias MoodleNet.Repo

  import ActivityPub.Entity, only: [local_id: 1]
  @moduletag format: :json

  test "email should be whitelist", %{conn: conn} do
    query = """
      mutation {
        createUser(
          user: {
            preferredUsername: "alexcastano"
            name: "Alejandro Castaño"
            summary: "Summary"
            location: "MoodleNet"
            icon: "https://imag.es/alexcastano"
            email: "alexcastano@newworld.com"
            password: "password"
            primaryLanguage: "Elixir"
          }
        ) {
          token
          me {
            id
          }
        }
      }
    """

    assert [error] =
             conn
             |> Plug.Conn.put_req_header("accept-language", "es")
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("errors")

    assert %{
             "extra" => %{
               "validation" => "inclusion",
               "field" => "email"
             },
             "code" => "validation",
             "locations" => [%{"column" => 0, "line" => 2}],
             "message" => "You cannot register with this email address",
             "path" => ["createUser"]
           } = error
  end

  test "createUser errors", %{conn: conn} do
    MoodleNet.Accounts.add_email_to_whitelist("alexcastano@newworld.com")
    query = """
      mutation {
        createUser(
          user: {
            preferredUsername: "alexcastano"
            name: "Alejandro Castaño"
            summary: "Summary"
            location: "MoodleNet"
            icon: "https://imag.es/alexcastano"
            email: "alexcastano@newworld.com"
            password: "short"
            primaryLanguage: "Elixir"
          }
        ) {
          token
          me {
            id
          }
        }
      }
    """

    assert [error] =
             conn
             |> Plug.Conn.put_req_header("accept-language", "es")
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("errors")

    assert %{
             "extra" => %{
               "count" => 6,
               "kind" => "min",
               "validation" => "length",
               "field" => "password"
             },
             "code" => "validation",
             "locations" => [%{"column" => 0, "line" => 2}],
             "message" => "should be at least 6 character(s)",
             "path" => ["createUser"]
           } = error
  end

  test "confirm email", %{conn: conn} do
    query = """
    mutation {
      confirmEmail(token: "not_real_token")
    }
    """

    assert [
             %{
               "code" => "not_found",
               "extra" => %{"type" => "Token", "value" => "not_real_token"},
               "message" => "Token not found"
             }
           ] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("errors")

    %{email_confirmation_token: %{token: token}} = Factory.full_user()

    query = """
    mutation {
      confirmEmail(token: "#{token}")
    }
    """

    assert true =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("confirmEmail")
  end

  test "reset password flow", %{conn: conn} do
    query = """
    mutation {
      resetPasswordRequest(email: "not_real@email.es")
    }
    """

    assert true =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("resetPasswordRequest")

    user = Factory.user()

    query = """
    mutation {
      resetPasswordRequest(email: "#{user.email}")
    }
    """

    assert true =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("resetPasswordRequest")

    assert %{token: token} = Repo.get_by!(MoodleNet.Accounts.ResetPasswordToken, user_id: user.id)

    query = """
    mutation {
      resetPassword(
        token: "#{token}"
        password: "new_password"
      )
    }
    """

    assert true =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("resetPassword")

    query = """
    mutation {
      resetPassword(
        token: "not_real_token"
        password: "new_password"
      )
    }
    """

    assert [
             %{
               "code" => "not_found",
               "extra" => %{"type" => "Token", "value" => "not_real_token"},
               "message" => "Token not found"
             }
           ] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("errors")
  end

  @tag :user
  test "copy a resource", %{conn: conn} do
    community = Factory.community()
    collection = Factory.collection(community)
    resource = Factory.resource(collection)

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

  test "delete an account", %{conn: conn} do
    actor = Factory.actor()
    community = Factory.community()
    comment = Factory.comment(actor, community)

    query = """
      mutation {
        createSession(
          email: "#{actor["email"]}"
          password: "password"
        ) {
          token
        }
      }
    """

    assert token =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("createSession")
             |> Map.fetch!("token")

    conn = conn |> put_req_header("authorization", "Bearer #{token}")

    query = """
      mutation {
        deleteUser
      }
    """

    assert true ==
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("deleteUser")

    query = """
    {
      me {
        id
      }
    }
    """

    assert [
             %{
               "code" => "unauthorized",
               "message" => "You have to log in to proceed"
             }
           ] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("errors")

    query = """
    {
      comment(local_id: #{local_id(comment)}) {
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
  end

  @tag :user
  test "delete a community", %{conn: conn, actor: actor} do
    community = Factory.community()
    collection = Factory.collection(community)
    resource = Factory.resource(collection)
    com_comment = Factory.comment(actor, community)
    col_comment = Factory.comment(actor, collection)

    query = """
    mutation {
      deleteCommunity(local_id: #{local_id(community)})
    }
    """

    assert true ==
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("deleteCommunity")

    query = """
    {
      community(local_id: #{local_id(community)}) {
        id
      }
    }
    """

    assert nil ==
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")

    query = """
    {
      collection(local_id: #{local_id(collection)}) {
        id
      }
    }
    """

    assert nil ==
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collection")

    query = """
    {
      resource(local_id: #{local_id(resource)}) {
        id
      }
    }
    """

    assert nil ==
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("resource")

    query = """
    {
      comment(local_id: #{local_id(col_comment)}) {
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
    {
      comment(local_id: #{local_id(com_comment)}) {
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
  end

  @tag :user
  test "delete a collection", %{conn: conn, actor: actor} do
    community = Factory.community()
    collection = Factory.collection(community)
    resource = Factory.resource(collection)
    comment = Factory.comment(actor, collection)

    query = """
    mutation {
      deleteCollection(local_id: #{local_id(collection)})
    }
    """

    assert true ==
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("deleteCollection")

    query = """
    {
      collection(local_id: #{local_id(collection)}) {
        id
      }
    }
    """

    assert nil ==
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collection")

    query = """
    {
      resource(local_id: #{local_id(resource)}) {
        id
      }
    }
    """

    assert nil ==
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("resource")

    query = """
    {
      comment(local_id: #{local_id(comment)}) {
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
  end

  @tag :user
  test "delete a resource", %{conn: conn} do
    community = Factory.community()
    collection = Factory.collection(community)
    resource = Factory.resource(collection)

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

    query = """
    {
      resource(local_id: #{local_id(resource)}) {
        id
      }
    }
    """

    assert nil ==
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("resource")
  end

  @tag :user
  test "delete comment", %{conn: conn, actor: actor} do
    community = Factory.community()
    comment = Factory.comment(actor, community)
    other_actor = Factory.actor()
    other_comment = Factory.comment(other_actor, community)

    query = """
    mutation {
      deleteComment(local_id: #{local_id(comment)})
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
      comment(local_id: #{local_id(comment)}) {
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
      deleteComment(local_id: #{local_id(other_comment)})
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
      comment(local_id: #{local_id(other_comment)}) {
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

  test "delete session", %{conn: conn} do
    actor = Factory.actor()

    query = """
      mutation {
        createSession(
          email: "#{actor["email"]}"
          password: "password"
        ) {
          token
        }
      }
    """

    assert token =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("createSession")
             |> Map.fetch!("token")

    conn = conn |> put_req_header("authorization", "Bearer #{token}")

    query = """
      mutation {
        deleteSession
      }
    """

    assert true ==
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("deleteSession")

    assert [
             %{
               "code" => "unauthorized",
               "message" => "You have to log in to proceed"
             }
           ] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("errors")
  end

  @tag :user
  test "update resource", %{conn: conn} do
    community = Factory.community()
    collection = Factory.collection(community)
    resource = Factory.resource(collection)

    query = """
    mutation {
      updateResource(
        resource_local_id: #{local_id(resource)},
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
    assert ret_resource["icon"] == "https://imag.es/resource"
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
      resource(local_id: #{local_id(resource)}) { id
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

  @tag :user
  test "update collection", %{conn: conn} do
    community = Factory.community()
    collection = Factory.collection(community)

    query = """
    mutation {
      updateCollection(
        collection_local_id: #{local_id(collection)},
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
        localId
        name
        summary
        content
        preferredUsername
        primaryLanguage
        icon
        published
        updated
        resourcesCount
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
    assert ret_collection["localId"]
    assert ret_collection["published"]
    assert ret_collection["updated"]
    assert ret_collection["resourcesCount"] == 3
    assert ret_collection["name"] == "collection_name"
    assert ret_collection["summary"] == "collection_summary"
    assert ret_collection["content"] == "collection_content"
    assert ret_collection["preferredUsername"] == "collection_preferredUser"
    assert ret_collection["primaryLanguage"] == "collection_language"
    assert ret_collection["icon"] == "https://imag.es/collection"

    query = """
    {
      collection(local_id: #{local_id(collection)}) {
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
        resourcesCount
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
  test "update community", %{conn: conn} do
    community = Factory.community()

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
          followingCount
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
        followingCount
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

  @tag :user
  test "update profile", %{conn: conn} do
    query = """
      mutation {
        updateProfile(
          profile: {
            preferredUsername: "alexcastano"
            name: "Alejandro Castaño"
            summary: "Summary"
            location: "MoodleNet"
            icon: "https://imag.es/alexcastano"
            primaryLanguage: "Elixir"
          }
        ) {
          id
          localId
          local
          type
          preferredUsername
          name
          summary
          location
          icon
          email
          primaryLanguage
        }
      }
    """

    assert me =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("updateProfile")

    assert me["preferredUsername"] == "alexcastano"
    assert me["name"] == "Alejandro Castaño"
    assert me["summary"] == "Summary"
    assert me["primaryLanguage"] == "Elixir"
    assert me["location"] == "MoodleNet"
    assert me["icon"] == "https://imag.es/alexcastano"

    query = """
    {
      me {
        id
        localId
        local
        type
        preferredUsername
        name
        summary
        location
        icon
        email
        primaryLanguage
      }
    }
    """

    assert me_2 =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("me")

    assert me == me_2
  end

  @tag :user
  test "unlike", %{conn: conn} do
    community = Factory.community()

    query = """
      mutation {
        unlike(
          localId: #{local_id(community)}
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
  test "likes", %{conn: conn, actor: actor} do
    community = Factory.community()

    query = """
      mutation {
        like(
          localId: #{local_id(community)}
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("like")

    query = """
    {
      communities {
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

    assert [community_map] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("communities")

    assert community_map["id"] == community.id
    assert community_map["localId"] == local_id(community)
    assert community_map["likesCount"] == 1

    assert [user_map] = community_map["likers"]
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
        unlike(
          localId: #{local_id(community)}
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("unlike")

    query = """
    {
      communities {
        id
        localId
        likesCount
        likers {
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
    assert community_map["likesCount"] == 0

    assert [] = community_map["likers"]

    query = """
      mutation {
        unlike(
          localId: #{local_id(community)}
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
  test "follows", %{conn: conn, actor: actor} do
    community = Factory.community()

    query = """
      mutation {
        follow(
          actorLocalId: #{local_id(community)}
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("follow")

    query = """
    {
      communities {
        id
        localId
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
        unfollow(
          actorLocalId: #{local_id(community)}
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("unfollow")

    query = """
    {
      communities {
        id
        localId
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
    assert community_map["followersCount"] == 0

    assert [] = community_map["followers"]

    collection = Factory.collection(community)

    query = """
      mutation {
        unfollow(
          actorLocalId: #{local_id(community)}
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
        follow(
          actorLocalId: #{local_id(collection)}
        )
      }
    """

    assert conn
           |> post("/api/graphql", %{query: query})
           |> json_response(200)
           |> Map.fetch!("data")
           |> Map.fetch!("follow")

    query = """
    {
      collections(communityLocalId: #{local_id(community)}) {
        id
        localId
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

    assert [collection_map] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collections")

    assert collection_map["id"] == collection.id
    assert collection_map["localId"] == local_id(collection)
    assert collection_map["followers"] == [user_map]
  end

  test "works", %{conn: conn} do
    query = """
      mutation {
        createUser(
          user: {
            preferredUsername: "alexcastano"
            name: "Alejandro Castaño"
            summary: "Summary"
            location: "MoodleNet"
            icon: "https://imag.es/alexcastano"
            email: "alexcastano@newworld.com"
            password: "password"
            primaryLanguage: "Elixir"
          }
        ) {
          token
          me {
            id
            localId
            local
            type
            preferredUsername
            name
            summary
            location
            icon
            email
            primaryLanguage
            comments {
              id
            }
          }
        }
      }
    """

    MoodleNet.Accounts.add_email_to_whitelist("alexcastano@newworld.com")
    assert auth_payload =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("createUser")

    assert auth_payload["token"]
    assert me = auth_payload["me"]
    assert me["preferredUsername"] == "alexcastano"
    assert me["name"] == "Alejandro Castaño"
    assert me["summary"] == "Summary"
    assert me["location"] == "MoodleNet"
    assert me["icon"] == "https://imag.es/alexcastano"
    assert me["email"] == "alexcastano@newworld.com"
    assert me["primaryLanguage"] == "Elixir"
    assert me["comments"] == []

    query = """
      mutation {
        createSession(
          email: "alexcastano@newworld.com"
          password: "password"
        ) {
          token
          me {
            id
            localId
            local
            type
            preferredUsername
            name
            summary
            location
            icon
            email
            primaryLanguage
            comments {
              id
            }
          }
        }
      }
    """

    assert auth_payload =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("createSession")

    assert auth_payload["token"]
    assert me == auth_payload["me"]

    query = """
      {
        me {
          id
          localId
          local
          type
          preferredUsername
          name
          summary
          location
          icon
          email
          primaryLanguage
          comments {
            id
          }
        }
      }
    """

    assert [
             %{
               "code" => "unauthorized",
               "message" => "You have to log in to proceed"
             }
           ] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("errors")

    conn = conn |> put_req_header("authorization", "Bearer #{auth_payload["token"]}")

    assert other_me =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("me")

    assert me == other_me

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
          followingCount
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
    assert community["followingCount"] == 15

    query = """
    mutation {
      createCollection(
        community_local_id: #{community["localId"]},
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
        localId
        name
        summary
        content
        preferredUsername
        primaryLanguage
        icon
        published
        updated
        resourcesCount
        communities {
          id
          localId
          name
          summary
          content
          preferredUsername
          primaryLanguage
          icon
          followingCount
          published
          updated
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
    assert collection["localId"]
    assert collection["published"]
    assert collection["updated"]
    assert collection["resourcesCount"] == 3
    assert collection["name"] == "collection_name"
    assert collection["summary"] == "collection_summary"
    assert collection["content"] == "collection_content"
    assert collection["preferredUsername"] == "collection_preferredUser"
    assert collection["primaryLanguage"] == "collection_language"
    assert collection["icon"] == "https://imag.es/collection"
    assert collection["communities"] == [community]

    query = """
    mutation {
      createResource(
        collection_local_id: #{collection["localId"]},
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
        collections {
          id
          localId
          name
          summary
          content
          preferredUsername
          primaryLanguage
          icon
          resourcesCount
          published
          updated
          communities {
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
            followingCount
          }
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
    assert resource["icon"] == "https://imag.es/resource"
    assert resource["collections"] == [collection]
    assert resource["sameAs"] == "same_as"
    assert resource["inLanguage"] == ["language"]
    assert resource["publicAccess"] == true
    assert resource["isAccesibleForFree"] == true
    assert resource["license"] == "license"
    assert resource["learningResourceType"] == "learning_resource_type"
    assert resource["educationalUse"] == ["educational_use"]
    assert resource["timeRequired"] == 60
    assert resource["typicalAgeRange"] == "typical_age_range"

    query = """
    mutation {
      createThread(
        context_local_id: #{community["localId"]},
        comment: {
          content:"comment_1"
        }
      ) {
          id
          localId
          local
          type
          content
          repliesCount
          published
          updated
          author {
            id
            localId
            local
            type
            preferredUsername
            name
            summary
            icon
            location
            primaryLanguage
          }
          inReplyTo {
            id
            localId
            local
            type
            content
            repliesCount
            published
            updated
            author {
              id
              localId
              local
              type
              preferredUsername
              name
              summary
              icon
              location
            }
          }
          replies {
            id
            localId
            local
            type
            content
            repliesCount
            published
            updated
            author {
              id
              localId
              local
              type
              preferredUsername
              name
              summary
              icon
              location
            }
          }
      }
    }
    """

    assert comment_1 =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("createThread")

    assert comment_1["id"]
    assert comment_1["localId"]
    assert comment_1["local"] == true
    assert comment_1["type"] == ["Object", "Note"]
    assert comment_1["updated"]
    assert comment_1["published"]
    assert comment_1["content"] == "comment_1"
    assert comment_1["repliesCount"] == 1

    assert comment_1["replies"] == []
    assert comment_1["inReplyTo"] == nil

    author = Map.drop(me, ["email", "comments"])
    assert comment_1["author"] == author

    query = """
    mutation {
      createReply(
        in_reply_to_local_id: #{comment_1["localId"]},
        comment: {
          content:"comment_2"
        }
      ) {
          id
          localId
          local
          type
          content
          repliesCount
          published
          updated
          author {
            id
            localId
            local
            type
            preferredUsername
            name
            summary
            icon
            location
            primaryLanguage
          }
          inReplyTo {
            id
            localId
            local
            type
            content
            repliesCount
            published
            updated
            author {
              id
              localId
              local
              type
              preferredUsername
              name
              summary
              icon
              location
              primaryLanguage
            }
          }
          replies {
            id
            localId
            local
            type
            content
            repliesCount
            published
            updated
            author {
              id
              localId
              local
              type
              preferredUsername
              name
              summary
              icon
              location
              primaryLanguage
            }
          }
      }
    }
    """

    assert comment_2 =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("createReply")

    assert comment_2["id"]
    assert comment_2["localId"]
    assert comment_2["local"] == true
    assert comment_2["type"] == ["Object", "Note"]
    assert comment_2["updated"]
    assert comment_2["published"]
    assert comment_2["content"] == "comment_2"
    assert comment_2["repliesCount"] == 1

    in_reply_to = Map.drop(comment_1, ["replies", "inReplyTo"])
    assert comment_2["replies"] == []
    assert comment_2["inReplyTo"] == in_reply_to
    assert comment_2["author"] == author

    query = """
    {
      communities {
        id
        localId
        name
        summary
        content
        preferredUsername
        primaryLanguage
        icon
        followingCount
        published
        updated
        comments {
          id
        }
        collections {
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
          resourcesCount
          resources {
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
      }
    }
    """

    assert [fetched_community] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("communities")

    assert community == Map.drop(fetched_community, ["collections", "comments"])
    assert comment_1["id"] == get_in(fetched_community, ["comments", Access.at(0), "id"])
    assert [fetched_collection] = fetched_community["collections"]
    assert Map.drop(collection, ["communities"]) == Map.drop(fetched_collection, ["resources"])
    # FIXME
    # assert [fetched_resource] = fetched_community["resources"]
    # assert Map.drop(resource, ["collections"]) == fetched_collection

    query = """
    {
      community(local_id: #{community["localId"]}) {
        id
        localId
      }
    }
    """

    assert fetched_community =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("community")

    assert fetched_community["localId"] == community["localId"]
    assert fetched_community["id"] == community["id"]

    query = """
    {
      collections(communityLocalId: #{community["localId"]}) {
        id
        localId
      }
    }
    """

    assert [fetched_collection] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collections")

    assert fetched_collection["localId"] == collection["localId"]
    assert fetched_collection["id"] == collection["id"]

    query = """
    {
      collection(localId: #{collection["localId"]}) {
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
        resourcesCount
        resources {
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
        communities {
          id
          localId
          name
          summary
          content
          preferredUsername
          primaryLanguage
          icon
          followingCount
          published
          updated
          comments {
            id
          }
        }
      }
    }
    """

    assert fetched_collection =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("collection")

    assert Map.drop(collection, ["communities"]) ==
             Map.drop(fetched_collection, ["communities", "resources"])

    assert [fetched_resource] = fetched_collection["resources"]
    assert Map.drop(resource, ["collections"]) == Map.drop(fetched_resource, ["collections"])
    assert [fetched_community] = fetched_collection["communities"]
    assert Map.drop(community, ["collections"]) == Map.drop(fetched_community, ["comments"])
    assert comment_1["id"] == get_in(fetched_community, ["comments", Access.at(0), "id"])

    query = """
    {
      resources(collectionLocalId: #{collection["localId"]}) {
        id
        localId
        collections {
          id
        }
      }
    }
    """

    assert [fetched_resource] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("resources")

    assert fetched_resource["localId"] == resource["localId"]
    assert fetched_resource["id"] == resource["id"]
    assert get_in(fetched_resource, ["collections", Access.at(0), "id"]) == collection["id"]

    query = """
    {
      resource(localId: #{resource["localId"]}) {
        id
        localId
        collections {
          id
        }
      }
    }
    """

    assert fetched_resource =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("resource")

    assert fetched_resource["localId"] == resource["localId"]
    assert fetched_resource["id"] == resource["id"]
    assert get_in(fetched_resource, ["collections", Access.at(0), "id"]) == collection["id"]

    query = """
    {
      comments(contextLocalId: #{community["localId"]}) {
        id
      }
    }
    """

    assert fetched_comments =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("comments")

    assert fetched_comments |> Enum.map(& &1["id"]) |> MapSet.new() ==
             MapSet.new([comment_1["id"], comment_2["id"]])

    query = """
    {
      replies(inReplyToLocalId: #{comment_1["localId"]}) {
        id
      }
    }
    """

    assert [fetched_comment] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("replies")

    assert fetched_comment["id"] == comment_2["id"]

    query = """
    {
      comment(localId: #{comment_1["localId"]}) {
        id
      }
    }
    """

    assert fetched_comment =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("comment")

    assert fetched_comment["id"] == comment_1["id"]

    query = """
    {
      me {
        comments {
          id
        }
      }
    }
    """

    assert %{"comments" => fetched_comments} =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("me")

    assert fetched_comments |> Enum.map(& &1["id"]) |> MapSet.new() ==
             MapSet.new([comment_1["id"], comment_2["id"]])
  end
end
