defmodule MoodleNetWeb.GraphQL.UserSchemaTest do
  use MoodleNetWeb.ConnCase

  import ActivityPub.Entity, only: [local_id: 1]
  @moduletag format: :json

  describe "createUser" do
    test "register user", %{conn: conn} do
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
              email
              user {
                id
                localId
                local
                type
                preferredUsername
                name
                summary
                location
                icon
                primaryLanguage
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
      assert me["email"] == "alexcastano@newworld.com"
      assert user = me["user"]
      assert user["preferredUsername"] == "alexcastano"
      assert user["name"] == "Alejandro Castaño"
      assert user["summary"] == "Summary"
      assert user["location"] == "MoodleNet"
      assert user["icon"] == "https://imag.es/alexcastano"
      assert user["primaryLanguage"] == "Elixir"
    end

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
              email
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
              email
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
               "path" => ["createUser"]
             } = error

      assert error["message"] == "debería tener al menos 6 elemento(s)"
    end
  end

  test "create session", %{conn: conn} do
    actor = Factory.actor()

    query = """
      mutation {
        createSession(
          email: "#{actor["email"]}"
          password: "password"
        ) {
          token
          me {
            email
            user {
              id
              localId
              local
              type
              preferredUsername
              name
              summary
              location
              icon
              primaryLanguage
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
    assert me = auth_payload["me"]
    assert me["email"] == actor["email"]
    assert user = me["user"]
    assert user["preferredUsername"] == actor.preferred_username
    assert user["name"] == actor.name["und"]
    assert user["summary"] == actor.summary["und"]
    assert user["location"] == get_in(actor, [:location, Access.at(0), :content, "und"])
    assert user["icon"] == get_in(actor, [:icon, Access.at(0), :url, Access.at(0)])
    assert user["primaryLanguage"] == actor["primary_language"]
  end

  test "reject unauthenticated user", %{conn: conn} do
    query = """
      {
        me {
          email
        }
      }
    """

    assert [
             %{
               "code" => "unauthorized",
               "message" => "You need to log in first"
             }
           ] =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("errors")

    user = Factory.user()
    token = Factory.oauth_token(user)

    assert me =
             conn
             |> put_req_header("authorization", "Bearer #{token.hash}")
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("me")

    assert me["email"] == user.email
  end

  @tag :user
  test "get user", %{conn: conn, actor: actor} do
    local_id = local_id(actor)

    query = """
    {
      user(localId: #{local_id}) {
        id
        localId
        local
        type
        preferredUsername
        name
        summary
        location
        icon
        primaryLanguage
      }
    }
    """

    assert user =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("user")

    assert user["id"] == actor.id
    assert user["localId"] == local_id
    assert user["preferredUsername"] == actor.preferred_username
    assert user["name"] == actor.name["und"]
    assert user["summary"] == actor.summary["und"]
    assert user["location"] == get_in(actor, [:location, Access.at(0), :content, "und"])
    assert user["icon"] == get_in(actor, [:icon, Access.at(0), :url, Access.at(0)])
    assert user["primaryLanguage"] == actor["primary_language"]
  end

  @tag :user
  test "joined_communities connection", %{conn: conn, actor: actor} do
    local_id = local_id(actor)

    query = """
      {
        user(localId: #{local_id}) {
          joinedCommunities {
            pageInfo {
              startCursor
              endCursor
            }
            edges {
              cursor
              node {
                id
                collections {
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
             |> Map.fetch!("user")
             |> Map.fetch!("joinedCommunities")

    assert %{
             "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
             "edges" => [],
             "totalCount" => 0
           } = ret

    owner = Factory.actor()
    %{id: a_id} = a = Factory.community(owner)
    %{id: b_id} = b = Factory.community(owner)

    MoodleNet.join_community(actor, b)
    MoodleNet.join_community(actor, a)

    assert ret =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("user")
             |> Map.fetch!("joinedCommunities")

    assert %{
             "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
             "edges" => edges,
             "totalCount" => 2
           } = ret

    assert [
             %{
               "cursor" => cursor_a,
               "node" => %{
                 "id" => ^a_id
               }
             },
             %{
               "cursor" => cursor_b,
               "node" => %{
                 "id" => ^b_id
               }
             }
           ] = edges

    assert cursor_a
    assert cursor_b
    assert cursor_a > cursor_b
  end

  @tag :user
  test "following collections connection", %{conn: conn, actor: actor} do
    local_id = local_id(actor)

    query = """
      {
        user(localId: #{local_id}) {
          followingCollections {
            pageInfo {
              startCursor
              endCursor
            }
            edges {
              cursor
              node {
                id
                resources {
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
             |> Map.fetch!("user")
             |> Map.fetch!("followingCollections")

    assert %{
             "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
             "edges" => [],
             "totalCount" => 0
           } = ret

    owner = Factory.actor()
    comm = Factory.community(owner)
    %{id: a_id} = a = Factory.collection(owner, comm)
    %{id: b_id} = b = Factory.collection(owner, comm)

    MoodleNet.follow_collection(actor, b)
    MoodleNet.follow_collection(actor, a)

    assert ret =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("user")
             |> Map.fetch!("followingCollections")

    assert %{
             "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
             "edges" => edges,
             "totalCount" => 2
           } = ret

    assert [
             %{
               "cursor" => cursor_a,
               "node" => %{
                 "id" => ^a_id
               }
             },
             %{
               "cursor" => cursor_b,
               "node" => %{
                 "id" => ^b_id
               }
             }
           ] = edges

    assert cursor_a
    assert cursor_b
    assert cursor_a > cursor_b
  end

  @tag :user
  test "created comments connection", %{conn: conn, actor: actor} do
    local_id = local_id(actor)

    query = """
      {
        user(localId: #{local_id}) {
          comments {
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
             |> Map.fetch!("user")
             |> Map.fetch!("comments")

    assert %{
             "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
             "edges" => [],
             "totalCount" => 0
           } = ret

    comm = Factory.community(actor)
    %{id: a_id} = Factory.comment(actor, comm)
    %{id: b_id} = Factory.comment(actor, comm)

    assert ret =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("user")
             |> Map.fetch!("comments")

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
  test "update profile", %{conn: conn, actor: actor} do
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
          email
          user {
            id
            localId
            local
            type
            preferredUsername
            name
            summary
            location
            icon
            primaryLanguage
          }
        }
      }
    """

    assert me =
             conn
             |> post("/api/graphql", %{query: query})
             |> json_response(200)
             |> Map.fetch!("data")
             |> Map.fetch!("updateProfile")

    assert me["email"] == actor["email"]
    assert user = me["user"]
    assert user["preferredUsername"] == "alexcastano"
    assert user["name"] == "Alejandro Castaño"
    assert user["summary"] == "Summary"
    assert user["primaryLanguage"] == "Elixir"
    assert user["location"] == "MoodleNet"
    assert user["icon"] == "https://imag.es/alexcastano"
  end
end
