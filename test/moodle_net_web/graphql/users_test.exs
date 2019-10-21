# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.UsersTest do
  use MoodleNetWeb.ConnCase, async: true

  # alias MoodleNet.Whitelists
  # import MoodleNet.MediaProxy.URLBuilder, only: [encode: 1]
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNet.Test.Faking
  import MoodleNetWeb.Test.ConnHelpers
  alias MoodleNet.Test.Fake
  alias MoodleNet.{Actors, OAuth, Whitelists}

  @user_basic_fields "id local preferredUsername name summary location website icon image primaryLanguage"

  describe "UsersResolver.username_available" do
    test "works for a guest" do
      query = "{ usernameAvailable(username: \"#{Fake.preferred_username()}\") }"
      assert true == Map.fetch!(gql_post_data(%{query: query}), "usernameAvailable")

      actor = fake_actor!()
      query = "{ usernameAvailable(username: \"#{actor.preferred_username}\") }"
      assert false == Map.fetch!(gql_post_data(%{query: query}), "usernameAvailable")
    end

    test "works for a logged in user" do
      user = fake_user!()
      {:ok, actor} = Actors.fetch_by_alias(user.id)
      conn = user_conn(user)
      query = "{ usernameAvailable(username: \"#{Fake.preferred_username()}\") }"
      assert true == Map.fetch!(gql_post_data(conn, %{query: query}), "usernameAvailable")

      query = "{ usernameAvailable(username: \"#{actor.preferred_username}\") }"
      assert false == Map.fetch!(gql_post_data(conn, %{query: query}), "usernameAvailable")
    end
  end

  describe "UsersResolver.me" do
    test "Works for a logged in user" do
      user = fake_user!()
      conn = user_conn(user)
      query = "{ me { email user { #{@user_basic_fields} }} }"

      assert %{"email" => email, "user" => user2} =
               Map.fetch!(gql_post_data(conn, %{query: query}), "me")

      assert user.email == email
      assert %{"id" => id, "preferredUsername" => preferred_username} = user2
      assert user.actor.id == id
      assert user.actor.preferred_username == preferred_username
      assert %{"name" => name, "summary" => summary} = user2
      assert user.actor.current.name == name
      assert user.actor.current.summary == summary
      # assert %{"location" => location, "website" => website} = user2
      # assert user.actor.current.location == user2["location"]
      # assert user.actor.current.website == user2["website"]
      assert %{"icon" => icon, "image" => image} = user2
      assert user.actor.current.icon == icon
      assert user.actor.current.image == image
      # assert user.actor.current.primary_language == user2["primaryLanguage"]
    end

    test "Does not work for a guest" do
      query = "{ me { email user { #{@user_basic_fields} }} }"
      assert_not_logged_in(gql_post_errors(%{query: query}), ["me"])
    end
  end

  describe "UsersResolver.user" do
    test "Works for a logged in user" do
      user = fake_user!(%{is_public: true})
      conn = user_conn(user)
      query = "{ user(id: \"#{user.actor.id}\") { #{@user_basic_fields} } }"
      user2 = Map.fetch!(gql_post_data(conn, %{query: query}), "user")
      assert %{"id" => id, "preferredUsername" => preferred_username} = user2
      assert user.actor.id == id
      assert user.actor.preferred_username == preferred_username
      assert %{"name" => name, "summary" => summary} = user2
      assert user.actor.current.name == name
      assert user.actor.current.summary == summary
      # assert %{"location" => location, "website" => website} = user2
      # assert user.actor.current.location == user2["location"]
      # assert user.actor.current.website == user2["website"]
      assert %{"icon" => icon, "image" => image} = user2
      assert user.actor.current.icon == icon
      assert user.actor.current.image == image
      # assert user.actor.current.primary_language == user2["primaryLanguage"]
    end

    test "Does not work for a guest" do
      user = fake_user!()
      query = "{ user(id: \"#{user.actor.id}\") { #{@user_basic_fields} } }"
      assert_not_logged_in(gql_post_errors(%{query: query}), ["user"])
    end

    test "Does not work for a user that is not public" do
      user = fake_user!(%{is_public: false})
      conn = user_conn(user)
      query = "{ user(id: \"#{user.actor.id}\") { #{@user_basic_fields} }}"
      # TODO: ensure this is correct, we may want unauthorized
      assert_not_found(gql_post_errors(conn, %{query: query}), ["user"])
    end
  end

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
    test "Works for a guest with good inputs" do
      reg = Fake.registration_input()
      assert {:ok, _} = Whitelists.create_register_email(reg["email"])

      query = """
        mutation Test($user: RegistrationInput){
          createUser(user:$user) {
            me { email user { #{@user_basic_fields} } }
          }
        }
      """

      query = %{operationName: "Test", query: query, variables: %{"user" => reg}}
      Map.fetch!(gql_post_data(json_conn(), query), "createUser")
      # assert {:ok, _} = Whitelists.create_register_email(reg["email"])
      # Map.fetch!(gql_post_data(conn, query), "createUser")
    end

    test "Does not work for a logged in user" do
      reg = Fake.registration_input()
      assert {:ok, _} = Whitelists.create_register_email(reg["email"])

      query = """
        mutation Test($user: RegistrationInput) {
          createUser(user:$user) {
            me { email user { #{@user_basic_fields} } }
          }
        }
      """

      query = %{operationName: "Test", query: query, variables: %{"user" => reg}}
      user = fake_user!()
      conn = user_conn(user)
      assert_not_permitted(gql_post_errors(conn, query), ["createUser"])
    end

    @tag :skip
    test "Does not work for a taken preferred username" do
    end

    @tag :skip
    test "Does not work for a taken email" do
    end
  end

  describe "UsersResolver.update_profile" do
    test "Works for a logged in user" do
      user = fake_user!()
      conn = user_conn(user)

      query = %{
        query: """
        mutation Test($profile: UpdateProfileInput!) {
          updateProfile(profile: $profile) {
            user { #{@user_basic_fields} }
          }
        }
        """,
        operationName: "Test",
        variables: %{"profile" => Fake.profile_update_input()}
      }

      assert data = gql_post_data(conn, query)["updateProfile"]
      assert MapSet.new(Map.keys(data["user"])) == MapSet.new(String.split(@user_basic_fields))
    end

    test "Does not work for a guest" do
      query = %{
        query: """
        mutation Test($profile: UpdateProfileInput!) {
          updateProfile(profile: $profile) {
            user { #{@user_basic_fields} }
          }
        }
        """,
        operationName: "Test",
        variables: %{"profile" => Fake.profile_update_input()}
      }

      assert_not_logged_in(gql_post_errors(query), ["updateProfile"])
    end
  end

  describe "UsersResolver.delete_user" do
    @tag :skip
    test "Works for a logged in user" do
    end

    test "Does not work for a guest" do
      query = "{ me { email } }"
      assert_not_logged_in(gql_post_errors(%{query: query}), ["me"])
    end
  end

  describe "UsersResolver.reset_password_request" do
    @tag :skip
    test "Works for a guest" do
    end

    @tag :skip
    test "Does not work for a logged in user" do
      user = fake_user!()
      query = "mutation { resetPasswordRequest(email: \"#{user.email}\") }"
      assert_not_logged_in(gql_post_errors(%{query: query}), ["me"])
    end
  end

  describe "UsersResolver.reset_password" do
    @tag :skip
    test "Works for a guest with a valid token" do
    end

    test "Does not work for a user" do
      query = "{ me { email } }"
      assert_not_logged_in(gql_post_errors(%{query: query}), ["me"])
    end
  end

  describe "UsersResolver.confirm_email" do
    test "Works for a guest with a valid token" do
      user = fake_user!()
      [token] = user.email_confirm_tokens
      query = "mutation { confirmEmail(token: \"#{token.id}\") }"

      auth_token = Map.fetch!(gql_post_data(%{query: query}), "confirmEmail")
      assert is_binary(auth_token)
    end

    test "Works with an authenticated user" do
      user = fake_user!()
      [token] = user.email_confirm_tokens
      query = "mutation { confirmEmail(token: \"#{token.id}\") }"

      auth_token = Map.fetch!(gql_post_data(%{query: query}), "confirmEmail")
      assert is_binary(auth_token)
    end

    test "Fails with an invalid token" do
      query = "mutation { confirmEmail(token: \"#{Faker.UUID.v4()}\") }"
      assert_not_found(gql_post_errors(%{query: query}), ["confirmEmail"])
    end
  end

  describe "UsersResolver.create_session" do
    test "Works with a valid email and password" do
      user = fake_user!(%{password: "password"})

      query = """
      mutation {
        createSession(email: \"#{user.email}\", password: \"password\") {
          token
          me {
            email
          }
        }
      }
      """

      assert resp = %{query: query} |> gql_post_data() |> Map.get("createSession")
      assert is_binary(resp["token"])
      assert resp["me"]["email"] == user.email
    end

    test "Does not work for a missing email" do
      query = """
      mutation {
        createSession(email: \"#{Fake.email()}\", password: \"#{Fake.password()}\") {
          token
        }
      }
      """

      assert_not_permitted(gql_post_errors(%{query: query}), ["createSession"])
    end

    test "Does not work with an invalid password" do
      user = fake_user!()

      query = """
      mutation {
        createSession(email: \"#{user.email}\", password: \"invalid\") {
          token
        }
      }
      """

      assert_not_permitted(gql_post_errors(%{query: query}), ["createSession"])
    end
  end

  describe "UsersResolver.delete_session" do
    test "Works with a logged in user" do
      user = fake_user!(%{password: "password"})
      assert {:ok, _} = OAuth.create_token(user, "password")

      conn = user_conn(user)
      query = "mutation { deleteSession }"
      assert conn |> gql_post_data(%{query: query}) |> Map.get("deleteSession")
    end

    test "Does not work for a guest" do
      query = "mutation { deleteSession }"
      assert_not_logged_in(gql_post_errors(%{query: query}), ["deleteSession"])
    end
  end

  describe "UsersResolver.flag_user" do
    @tag :skip
    test "Does not work for a guest" do
      query = "{ me { email } }"
      assert_not_logged_in(gql_post_errors(%{query: query}), ["me"])
    end
  end

  describe "UsersResolver.check_username_available" do
  end

  describe "UsersResolver.undo_flag_user" do
    @tag :skip
    test "Does not work for a guest" do
      query = "{ me { email } }"
      assert_not_logged_in(gql_post_errors(%{query: query}), ["me"])
    end
  end
end
