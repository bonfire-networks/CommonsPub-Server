# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.UserSchemaTest do
  use MoodleNetWeb.ConnCase

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
              website: "test.tld"
            }
          ) {
            token
            me {
              email
              user {
                id
                local
                type
                preferredUsername
                name
                summary
                location
                icon
                primaryLanguage
                website
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
      assert user["website"] == "test.tld"
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
    query = """
    {
      user(id: "#{actor.id}") {
        id
        local
        type
        preferredUsername
        name
        summary
        location
        website
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
    assert user["preferredUsername"] == actor.preferred_username
    assert user["name"] == actor.name["und"]
    assert user["summary"] == actor.summary["und"]
    assert user["location"] == get_in(actor, [:location, Access.at(0), :content, "und"])
    assert user["website"] == get_in(actor, [:attachment, Access.at(0), "value"])
    assert user["icon"] == get_in(actor, [:icon, Access.at(0), :url, Access.at(0)])
    assert user["primaryLanguage"] == actor["primary_language"]
  end

  @tag :user
  test "joined_communities connection", %{conn: conn, actor: actor} do
    query = """
      {
        user(id: "#{actor.id}") {
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
    query = """
      {
        user(id: "#{actor.id}") {
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
    query = """
      {
        user(id: "#{actor.id}") {
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
            website: "test.tld"
          }
        ) {
          email
          user {
            id
            local
            type
            preferredUsername
            name
            summary
            location
            website
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
    assert user["website"] == "test.tld"
    assert user["icon"] == "https://imag.es/alexcastano"
  end

  @tag :user
  test "inbox connection", %{conn: conn, actor: actor} do
    owner = Factory.actor()
    community = Factory.community(owner)
    MoodleNet.join_community(actor, community)

    MoodleNet.update_community(owner, community, %{name: "Name"})

    collection = Factory.collection(owner, community)
    MoodleNet.update_collection(owner, collection, %{name: "Name"})
    MoodleNet.like_collection(owner, collection)

    resource = Factory.resource(owner, collection)
    MoodleNet.update_resource(owner, resource, %{name: "Name"})
    MoodleNet.like_resource(owner, resource)

    comment = Factory.comment(owner, collection)
    reply = Factory.reply(owner, comment)
    MoodleNet.like_comment(owner, comment)
    MoodleNet.like_comment(owner, reply)

    comment = Factory.comment(owner, community)
    reply = Factory.reply(owner, comment)
    MoodleNet.like_comment(owner, comment)
    MoodleNet.like_comment(owner, reply)

    query = """
      {
        user(id: "#{actor.id}") {
          inbox {
            pageInfo {
              startCursor
              endCursor
            }
            edges {
              cursor
              node {
                id
                activityType
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
             |> Map.fetch!("inbox")

    assert %{
             "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
             "edges" => edges,
             "totalCount" => 12
           } = ret

    assert [
             %{
               "node" => %{
                 "activityType" => "LikeComment"
               }
             },
             %{
               "node" => %{
                 "activityType" => "LikeComment"
               }
             },
             %{
               "node" => %{
                 "activityType" => "CreateComment"
               }
             },
             %{
               "node" => %{
                 "activityType" => "CreateComment"
               }
             },
             %{
               "node" => %{
                 "activityType" => "UpdateResource"
               }
             },
             %{
               "node" => %{
                 "activityType" => "CreateResource"
               }
             },
             %{
               "node" => %{
                 "activityType" => "LikeCollection"
               }
             },
             %{
               "node" => %{
                 "activityType" => "UpdateCollection"
               }
             },
             %{
               "node" => %{
                 "activityType" => "FollowCollection"
               }
             },
             %{
               "node" => %{
                 "activityType" => "CreateCollection"
               }
             },
             %{
               "node" => %{
                 "activityType" => "UpdateCommunity"
               }
             },
             %{
               "node" => %{
                 "activityType" => "JoinCommunity"
               }
             }
           ] = edges
  end

  @tag :user
  test "outbox connection", %{conn: conn, actor: actor} do
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

    comment = Factory.comment(actor, community)
    reply = Factory.reply(actor, comment)
    MoodleNet.like_comment(actor, comment)
    MoodleNet.like_comment(actor, reply)

    query = """
      {
        user(id: "#{actor.id}") {
          outbox {
            pageInfo {
              startCursor
              endCursor
            }
            edges {
              cursor
              node {
                id
                activityType
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
             |> Map.fetch!("outbox")

    assert %{
             "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
             "edges" => edges,
             "totalCount" => 18
           } = ret

    assert [
             %{
               "node" => %{
                 "activityType" => "LikeComment"
               }
             },
             %{
               "node" => %{
                 "activityType" => "LikeComment"
               }
             },
             %{
               "node" => %{
                 "activityType" => "CreateComment"
               }
             },
             %{
               "node" => %{
                 "activityType" => "CreateComment"
               }
             },
             %{
               "node" => %{
                 "activityType" => "LikeComment"
               }
             },
             %{
               "node" => %{
                 "activityType" => "LikeComment"
               }
             },
             %{
               "node" => %{
                 "activityType" => "CreateComment"
               }
             },
             %{
               "node" => %{
                 "activityType" => "CreateComment"
               }
             },
             %{
               "node" => %{
                 "activityType" => "LikeResource"
               }
             },
             %{
               "node" => %{
                 "activityType" => "UpdateResource"
               }
             },
             %{
               "node" => %{
                 "activityType" => "CreateResource"
               }
             },
             %{
               "node" => %{
                 "activityType" => "LikeCollection"
               }
             },
             %{
               "node" => %{
                 "activityType" => "UpdateCollection"
               }
             },
             %{
               "node" => %{
                 "activityType" => "FollowCollection"
               }
             },
             %{
               "node" => %{
                 "activityType" => "CreateCollection"
               }
             },
             %{
               "node" => %{
                 "activityType" => "UpdateCommunity"
               }
             },
             %{
               "node" => %{
                 "activityType" => "JoinCommunity"
               }
             },
             %{
               "node" => %{
                 "activityType" => "CreateCommunity"
               }
             }
           ] = edges
  end
end
