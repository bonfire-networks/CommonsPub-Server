defmodule MoodleNetWeb.GraphQL.MoodleNetSchemaTest do
  # , async: true
  use MoodleNetWeb.ConnCase

  @moduletag format: :json

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

    assert "You are not logged in" ==
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("errors")
             |> hd()
             |> Map.fetch!("message")

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
          followersCount
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
    assert community["followersCount"] == 10
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
          followersCount
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
          primaryLanguage:"resource_language"
          icon:"https://imag.es/resource"
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
            followersCount
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
          likesCount
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
            likesCount
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
            likesCount
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
    assert comment_1["likesCount"] == 12
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
          likesCount
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
            likesCount
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
            likesCount
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
    assert comment_2["likesCount"] == 12
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
        followersCount
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
          followersCount
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
