# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.UsersTest do
  use MoodleNetWeb.ConnCase, async: true

  # alias MoodleNet.Whitelists
  # import MoodleNet.MediaProxy.URLBuilder, only: [encode: 1]
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNet.Test.Faking
  alias MoodleNet.Test.Fake

  describe "UsersResolver.username_available" do

    test "works as you'd expect" do
      query = "{ usernameAvailable(username: \"#{Fake.preferred_username()}\") }"
      assert true == Map.fetch!(gql_post_data(query), "usernameAvailable")

      actor = fake_actor!()
      query = "{ usernameAvailable(username: \"#{actor.preferred_username}\") }"
      assert false == Map.fetch!(gql_post_data(query), "usernameAvailable")
    end

  end

  describe "UsersResolver.me" do

    @tag :skip
    test "Works for a logged in user" do
      query = "{ me { email } }"
  #   user = Factory.user()
  #   token = Factory.oauth_token(user)

  #   assert me =
  #            conn
  #            |> put_req_header("authorization", "Bearer #{token.hash}")
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("me")

  #   assert me["email"] == user.email
    end

    test "Does not work for a guest" do
      query = "{ me { email } }"
      assert_unauthorized(gql_post_errors(query), ["me"])
    end

  end

  describe "UsersResolver.user" do

    @tag :skip
    test "Works for a logged in user" do
    end

    @tag :skip
    test "Does not work for a guest" do
      query = "{ me { email } }"
      assert_unauthorized(gql_post_errors(query), ["me"])
    end

  end

  # @tag :user
  # test "get user", %{conn: conn, actor: actor} do
  #   local_id = local_id(actor)

  #   query = """
  #   {
  #     user(localId: #{local_id}) {
  #       id
  #       localId
  #       local
  #       type
  #       preferredUsername
  #       name
  #       summary
  #       location
  #       website
  #       icon
  #       image
  #       primaryLanguage
  #     }
  #   }
  #   """

  #   assert user =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("user")

  #   assert user["id"] == actor.id
  #   assert user["localId"] == local_id
  #   assert user["preferredUsername"] == actor.preferred_username
  #   assert user["name"] == actor.name["und"]
  #   assert user["summary"] == actor.summary["und"]
  #   assert user["location"] == get_in(actor, [:location, Access.at(0), :content, "und"])
  #   assert user["website"] == get_in(actor, [:attachment, Access.at(0), "value"])
  #   assert user["icon"] == actor
  #   |> get_in([:icon, Access.at(0), :url, Access.at(0)])
  #   |> encode()
  #   assert user["image"] == actor
  #   |> get_in([:image, Access.at(0), :url, Access.at(0)])
  #   |> encode()
  #   assert user["primaryLanguage"] == actor["primary_language"]
  # end

  # @tag :user
  # test "joined_communities connection", %{conn: conn, actor: actor} do
  #   local_id = local_id(actor)

  #   query = """
  #     {
  #       user(localId: #{local_id}) {
  #         joinedCommunities {
  #           pageInfo {
  #             startCursor
  #             endCursor
  #           }
  #           edges {
  #             cursor
  #             node {
  #               id
  #               collections {
  #                 totalCount
  #               }
  #             }
  #           }
  #           totalCount
  #         }
  #       }
  #     }
  #   """

  #   assert ret =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("user")
  #            |> Map.fetch!("joinedCommunities")

  #   assert %{
  #            "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
  #            "edges" => [],
  #            "totalCount" => 0
  #          } = ret

  #   owner = Factory.actor()
  #   %{id: a_id} = a = Factory.community(owner)
  #   %{id: b_id} = b = Factory.community(owner)

  #   MoodleNet.join_community(actor, b)
  #   MoodleNet.join_community(actor, a)

  #   assert ret =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("user")
  #            |> Map.fetch!("joinedCommunities")

  #   assert %{
  #            "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
  #            "edges" => edges,
  #            "totalCount" => 2
  #          } = ret

  #   assert [
  #            %{
  #              "cursor" => cursor_a,
  #              "node" => %{
  #                "id" => ^a_id
  #              }
  #            },
  #            %{
  #              "cursor" => cursor_b,
  #              "node" => %{
  #                "id" => ^b_id
  #              }
  #            }
  #          ] = edges

  #   assert cursor_a
  #   assert cursor_b
  #   assert cursor_a > cursor_b
  # end

  # @tag :user
  # test "following collections connection", %{conn: conn, actor: actor} do
  #   local_id = local_id(actor)

  #   query = """
  #     {
  #       user(localId: #{local_id}) {
  #         followingCollections {
  #           pageInfo {
  #             startCursor
  #             endCursor
  #           }
  #           edges {
  #             cursor
  #             node {
  #               id
  #               resources {
  #                 totalCount
  #               }
  #             }
  #           }
  #           totalCount
  #         }
  #       }
  #     }
  #   """

  #   assert ret =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("user")
  #            |> Map.fetch!("followingCollections")

  #   assert %{
  #            "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
  #            "edges" => [],
  #            "totalCount" => 0
  #          } = ret

  #   owner = Factory.actor()
  #   comm = Factory.community(owner)
  #   %{id: a_id} = a = Factory.collection(owner, comm)
  #   %{id: b_id} = b = Factory.collection(owner, comm)

  #   MoodleNet.follow_collection(actor, b)
  #   MoodleNet.follow_collection(actor, a)

  #   assert ret =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("user")
  #            |> Map.fetch!("followingCollections")

  #   assert %{
  #            "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
  #            "edges" => edges,
  #            "totalCount" => 2
  #          } = ret

  #   assert [
  #            %{
  #              "cursor" => cursor_a,
  #              "node" => %{
  #                "id" => ^a_id
  #              }
  #            },
  #            %{
  #              "cursor" => cursor_b,
  #              "node" => %{
  #                "id" => ^b_id
  #              }
  #            }
  #          ] = edges

  #   assert cursor_a
  #   assert cursor_b
  #   assert cursor_a > cursor_b
  # end

  # @tag :user
  # test "created comments connection", %{conn: conn, actor: actor} do
  #   local_id = local_id(actor)

  #   query = """
  #     {
  #       user(localId: #{local_id}) {
  #         comments {
  #           pageInfo {
  #             startCursor
  #             endCursor
  #           }
  #           edges {
  #             cursor
  #             node {
  #               id
  #               author {
  #                 id
  #               }
  #             }
  #           }
  #           totalCount
  #         }
  #       }
  #     }
  #   """

  #   assert ret =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("user")
  #            |> Map.fetch!("comments")

  #   assert %{
  #            "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
  #            "edges" => [],
  #            "totalCount" => 0
  #          } = ret

  #   comm = Factory.community(actor)
  #   %{id: a_id} = Factory.comment(actor, comm)
  #   %{id: b_id} = Factory.comment(actor, comm)

  #   assert ret =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("user")
  #            |> Map.fetch!("comments")

  #   assert %{
  #            "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
  #            "edges" => edges,
  #            "totalCount" => 2
  #          } = ret

  #   assert [
  #            %{
  #              "cursor" => cursor_b,
  #              "node" => %{
  #                "id" => ^b_id
  #              }
  #            },
  #            %{
  #              "cursor" => cursor_a,
  #              "node" => %{
  #                "id" => ^a_id
  #              }
  #            }
  #          ] = edges

  #   assert cursor_a
  #   assert cursor_b
  #   assert cursor_b > cursor_a
  # end


  # @tag :user
  # test "inbox connection", %{conn: conn, actor: actor} do
  #   owner = Factory.actor()
  #   community = Factory.community(owner)
  #   MoodleNet.join_community(actor, community)

  #   MoodleNet.update_community(owner, community, %{name: "Name"})

  #   collection = Factory.collection(owner, community)
  #   MoodleNet.update_collection(owner, collection, %{name: "Name"})
  #   MoodleNet.like_collection(owner, collection)

  #   resource = Factory.resource(owner, collection)
  #   MoodleNet.update_resource(owner, resource, %{name: "Name"})
  #   MoodleNet.like_resource(owner, resource)

  #   comment = Factory.comment(owner, collection)
  #   reply = Factory.reply(owner, comment)
  #   MoodleNet.like_comment(owner, comment)
  #   MoodleNet.like_comment(owner, reply)

  #   comment = Factory.comment(owner, community)
  #   reply = Factory.reply(owner, comment)
  #   MoodleNet.like_comment(owner, comment)
  #   MoodleNet.like_comment(owner, reply)

  #   local_id = local_id(actor)

  #   query = """
  #     {
  #       user(localId: #{local_id}) {
  #         inbox {
  #           pageInfo {
  #             startCursor
  #             endCursor
  #           }
  #           edges {
  #             cursor
  #             node {
  #               id
  #               activityType
  #             }
  #           }
  #           totalCount
  #         }
  #       }
  #     }
  #   """

  #   assert ret =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("user")
  #            |> Map.fetch!("inbox")

  #   assert %{
  #            "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
  #            "edges" => edges,
  #            "totalCount" => 12
  #          } = ret

  #   assert [
  #            %{
  #              "node" => %{
  #                "activityType" => "LikeComment"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "LikeComment"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "CreateComment"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "CreateComment"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "UpdateResource"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "CreateResource"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "LikeCollection"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "UpdateCollection"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "FollowCollection"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "CreateCollection"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "UpdateCommunity"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "JoinCommunity"
  #              }
  #            }
  #          ] = edges
  # end

  # @tag :user
  # test "outbox connection", %{conn: conn, actor: actor} do
  #   community = Factory.community(actor)

  #   MoodleNet.update_community(actor, community, %{name: "Name"})

  #   collection = Factory.collection(actor, community)
  #   MoodleNet.update_collection(actor, collection, %{name: "Name"})
  #   MoodleNet.like_collection(actor, collection)

  #   resource = Factory.resource(actor, collection)
  #   MoodleNet.update_resource(actor, resource, %{name: "Name"})
  #   MoodleNet.like_resource(actor, resource)

  #   comment = Factory.comment(actor, collection)
  #   reply = Factory.reply(actor, comment)
  #   MoodleNet.like_comment(actor, comment)
  #   MoodleNet.like_comment(actor, reply)

  #   comment = Factory.comment(actor, community)
  #   reply = Factory.reply(actor, comment)
  #   MoodleNet.like_comment(actor, comment)
  #   MoodleNet.like_comment(actor, reply)

  #   local_id = local_id(actor)

  #   query = """
  #     {
  #       user(localId: #{local_id}) {
  #         outbox {
  #           pageInfo {
  #             startCursor
  #             endCursor
  #           }
  #           edges {
  #             cursor
  #             node {
  #               id
  #               activityType
  #             }
  #           }
  #           totalCount
  #         }
  #       }
  #     }
  #   """

  #   assert ret =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("user")
  #            |> Map.fetch!("outbox")

  #   assert %{
  #            "pageInfo" => %{"startCursor" => nil, "endCursor" => nil},
  #            "edges" => edges,
  #            "totalCount" => 18
  #          } = ret

  #   assert [
  #            %{
  #              "node" => %{
  #                "activityType" => "LikeComment"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "LikeComment"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "CreateComment"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "CreateComment"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "LikeComment"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "LikeComment"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "CreateComment"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "CreateComment"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "LikeResource"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "UpdateResource"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "CreateResource"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "LikeCollection"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "UpdateCollection"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "FollowCollection"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "CreateCollection"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "UpdateCommunity"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "JoinCommunity"
  #              }
  #            },
  #            %{
  #              "node" => %{
  #                "activityType" => "CreateCommunity"
  #              }
  #            }
  #          ] = edges
  # end

  describe "UsersResolver.create_user" do

    @tag :skip
    test "Works for a guest with good inputs" do
    end

    @tag :skip
    test "Does not work for a logged in user" do
    end

  end

  # describe "createUser" do
  #   test "register user", %{conn: conn} do
  #     query = """
  #       mutation {
  #         createUser(
  #           user: {
  #             preferredUsername: "alexcastano"
  #             name: "Alejandro Castaño"
  #             summary: "Summary"
  #             location: "MoodleNet"
  #             icon: "https://imag.es/alexcastano"
  #             image: "https://images.unsplash.com/flagged/photo-1551255868-86bbc8e0f971"
  #             email: "alexcastano@newworld.com"
  #             password: "password"
  #             primaryLanguage: "Elixir"
  #             website: "test.tld"
  #           }
  #         ) {
  #           token
  #           me {
  #             email
  #             user {
  #               id
  #               localId
  #               local
  #               type
  #               preferredUsername
  #               name
  #               summary
  #               location
  #               icon
  #               image
  #               primaryLanguage
  #               website
  #             }
  #           }
  #         }
  #       }
  #     """
  #     Whitelists.create_register_email("alexcastano@newworld.com")

  #     assert auth_payload =
  #              conn
  #              |> post("/api/graphql", %{query: query})
  #              |> json_response(200)
  #              |> Map.fetch!("data")
  #              |> Map.fetch!("createUser")

  #     assert auth_payload["token"]
  #     assert me = auth_payload["me"]
  #     assert me["email"] == "alexcastano@newworld.com"
  #     assert user = me["user"]
  #     assert user["preferredUsername"] == "alexcastano"
  #     assert user["name"] == "Alejandro Castaño"
  #     assert user["summary"] == "Summary"
  #     assert user["location"] == "MoodleNet"
  #     assert user["icon"] == encode("https://imag.es/alexcastano")
  #     assert user["image"] == encode("https://images.unsplash.com/flagged/photo-1551255868-86bbc8e0f971")
  #     assert user["primaryLanguage"] == "Elixir"
  #     assert user["website"] == "test.tld"
  #   end

  #   test "email should be whitelist", %{conn: conn} do
  #     query = """
  #       mutation {
  #         createUser(
  #           user: {
  #             preferredUsername: "alexcastano"
  #             name: "Alejandro Castaño"
  #             summary: "Summary"
  #             location: "MoodleNet"
  #             icon: "https://imag.es/alexcastano"
  #             email: "alexcastano@newworld.com"
  #             password: "password"
  #             primaryLanguage: "Elixir"
  #           }
  #         ) {
  #           token
  #           me {
  #             email
  #           }
  #         }
  #       }
  #     """

  #     assert [error] =
  #              conn
  #              |> Plug.Conn.put_req_header("accept-language", "es")
  #              |> post("/api/graphql", %{query: query})
  #              |> json_response(200)
  #              |> Map.fetch!("errors")

  #     assert %{
  #              "extra" => %{
  #                "validation" => "inclusion",
  #                "field" => "email"
  #              },
  #              "code" => "validation",
  #              "locations" => [%{"column" => 0, "line" => 2}],
  #              "message" => "You cannot register with this email address",
  #              "path" => ["createUser"]
  #            } = error
  #   end

  #   test "createUser errors", %{conn: conn} do
  #     MoodleNet.Accounts.add_email_to_whitelist("alexcastano@newworld.com")

  #     query = """
  #       mutation {
  #         createUser(
  #           user: {
  #             preferredUsername: "alexcastano"
  #             name: "Alejandro Castaño"
  #             summary: "Summary"
  #             location: "MoodleNet"
  #             icon: "https://imag.es/alexcastano"
  #             email: "alexcastano@newworld.com"
  #             password: "short"
  #             primaryLanguage: "Elixir"
  #           }
  #         ) {
  #           token
  #           me {
  #             email
  #           }
  #         }
  #       }
  #     """

  #     assert [error] =
  #              conn
  #              |> Plug.Conn.put_req_header("accept-language", "es")
  #              |> post("/api/graphql", %{query: query})
  #              |> json_response(200)
  #              |> Map.fetch!("errors")

  #     assert %{
  #              "extra" => %{
  #                "count" => 6,
  #                "kind" => "min",
  #                "validation" => "length",
  #                "field" => "password"
  #              },
  #              "code" => "validation",
  #              "locations" => [%{"column" => 0, "line" => 2}],
  #              "path" => ["createUser"]
  #            } = error

  #     assert error["message"] == "debería tener al menos 6 elemento(s)"
  #   end
  # end

  describe "UsersResolver.update_profile" do

    @tag :skip
    test "Works for a logged in user" do
    end

    @tag :skip
    test "Does not work for a guest" do
      query = "{ me { email } }"
      assert_unauthorized(gql_post_errors(query), ["me"])
    end

  end

  # @doc "TODO: Write better tests for changing the username"

  # @tag :user
  # test "update profile", %{conn: conn, actor: actor} do
  #   query = """
  #     mutation {
  #       updateProfile(
  #         profile: {
  #           name: "Alejandro Castaño"
  #           summary: "Summary"
  #           location: "MoodleNet"
  #           icon: "https://imag.es/alexcastano"
  #           image: "https://images.unsplash.com/flagged/photo-1551255868-86bbc8e0f971"
  #           primaryLanguage: "Elixir"
  #           website: "test.tld"
  #         }
  #       ) {
  #         email
  #         user {
  #           id
  #           localId
  #           local
  #           type
  #           preferredUsername
  #           name
  #           summary
  #           location
  #           website
  #           icon
  #           image
  #           primaryLanguage
  #         }
  #       }
  #     }
  #   """

  #   assert me =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("updateProfile")

  #   assert me["email"] == actor["email"]
  #   assert user = me["user"]
  #   assert user["preferredUsername"] == actor.preferred_username
  #   assert user["name"] == "Alejandro Castaño"
  #   assert user["summary"] == "Summary"
  #   assert user["primaryLanguage"] == "Elixir"
  #   assert user["location"] == "MoodleNet"
  #   assert user["website"] == "test.tld"
  #   assert user["icon"] == encode("https://imag.es/alexcastano")
  #   assert user["image"] == encode("https://images.unsplash.com/flagged/photo-1551255868-86bbc8e0f971")
  # end

  describe "UsersResolver.delete_user" do

    @tag :skip
    test "Works for a logged in user" do
    end

    @tag :skip
    test "Does not work for a guest" do
      query = "{ me { email } }"
      assert_unauthorized(gql_post_errors(query), ["me"])
    end

  end

  describe "UsersResolver.reset_password_request" do

    @tag :skip
    test "Works for a guest" do
    end

    @tag :skip
    test "Does not work for a logged in user" do
      query = "{ reset_password_request(\"\") }"
      assert_unauthorized(gql_post_errors(query), ["me"])
    end

  end

  describe "UsersResolver.reset_password" do
 
    @tag :skip
    test "Works for a guest with a valid token" do
      
    end

    @tag :skip
    test "Does not work for a user" do
      query = "{ me { email } }"
      assert_unauthorized(gql_post_errors(query), ["me"])
    end

 end

  describe "UsersResolver.confirm_email" do

    @tag :skip
    test "Does not work for a guest" do
      query = "{ me { email } }"
      assert_unauthorized(gql_post_errors(query), ["me"])
    end

  end

  describe "UsersResolver.create_session" do

    @tag :skip
    test "Does not work for a guest" do
      query = "{ me { email } }"
      assert_unauthorized(gql_post_errors(query), ["me"])
    end

  end

  # test "create session", %{conn: conn} do
  #   actor = Factory.actor()

  #   query = """
  #     mutation {
  #       createSession(
  #         email: "#{actor["email"]}"
  #         password: "password"
  #       ) {
  #         token
  #         me {
  #           email
  #           user {
  #             id
  #             localId
  #             local
  #             type
  #             preferredUsername
  #             name
  #             summary
  #             location
  #             icon
  #             image
  #             primaryLanguage
  #           }
  #         }
  #       }
  #     }
  #   """

  #   assert auth_payload =
  #            conn
  #            |> post("/api/graphql", %{query: query})
  #            |> json_response(200)
  #            |> Map.fetch!("data")
  #            |> Map.fetch!("createSession")

  #   assert auth_payload["token"]
  #   assert me = auth_payload["me"]
  #   assert me["email"] == actor["email"]
  #   assert user = me["user"]
  #   assert user["preferredUsername"] == actor.preferred_username
  #   assert user["name"] == actor.name["und"]
  #   assert user["summary"] == actor.summary["und"]
  #   assert user["location"] == get_in(actor, [:location, Access.at(0), :content, "und"])
  #   assert user["icon"] == actor
  #   |> get_in([:icon, Access.at(0), :url, Access.at(0)])
  #   |> encode()
  #   assert user["image"] == actor
  #   |> get_in([:image, Access.at(0), :url, Access.at(0)])
  #   |> encode()
  #   assert user["primaryLanguage"] == actor["primary_language"]
  # end

  describe "UsersResolver.delete_session" do

    @tag :skip
    test "Does not work for a guest" do
      query = "{ me { email } }"
      assert_unauthorized(gql_post_errors(query), ["me"])
    end

  end

  describe "UsersResolver.flag_user" do

    @tag :skip
    test "Does not work for a guest" do
      query = "{ me { email } }"
      assert_unauthorized(gql_post_errors(query), ["me"])
    end

  end

  describe "UsersResolver.undo_flag_user" do

    @tag :skip
    test "Does not work for a guest" do
      query = "{ me { email } }"
      assert_unauthorized(gql_post_errors(query), ["me"])
    end

  end

end
