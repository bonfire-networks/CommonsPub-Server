# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.TemporaryTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNet.Test.Fake
  import MoodleNetWeb.Test.GraphQLAssertions
  # import MoodleNet.Test.Faking
  # import MoodleNetWeb.Test.ConnHelpers
  # alias MoodleNet.Test.Fake
  # alias MoodleNet.{Actors, OAuth, Users, Access}

  @user_basics """
  id canonicalUrl preferredUsername
  name summary location website icon image
  isLocal isPublic isDisabled createdAt updatedAt __typename
  """
  @me_basics """
  email wantsEmailDigest wantsNotifications isConfirmed isInstanceAdmin __typename
  """
  @thread_basics  """
  id canonicalUrl
  isLocal isPublic isHidden createdAt updatedAt __typename
  """
  @comment_basics """
  id canonicalUrl inReplyToId content
  isLocal isPublic isHidden createdAt updatedAt __typename
  """
  @community_basics """
  id canonicalUrl preferredUsername
  name summary icon image
  isLocal isPublic isDisabled createdAt updatedAt __typename
  """
  @collection_basics """
  id canonicalUrl preferredUsername
  name summary icon
  isLocal isPublic isDisabled createdAt updatedAt __typename
  """
  @resource_basics """
  id canonicalUrl preferredUsername
  name summary icon
  isLocal isPublic isDisabled createdAt updatedAt __typename
  """
  @flag_basics """
  id canonicalUrl message isResolved
  isLocal isPublic createdAt updatedAt __typename
  """
  @like_basics """
  id canonicalUrl
  isLocal isPublic createdAt __typename
  """
  @follow_basics """
  id canonicalUrl
  isLocal isPublic createdAt __typename
  """
  @category_basics """
  id canonicalUrl name
  isLocal isPublic createdAt __typename
  """
  @tag_basics """
  id canonicalUrl name
  isLocal isPublic createdAt __typename
  """
  @tagging_basics """
  id canonicalUrl
  isLocal isPublic createdAt __typename
  """
  @activity_basics """
  id canonicalUrl verb
  isLocal isPublic createdAt __typename
  """

  @username_available_q """
  query Test($username: String!) {
    usernameAvailable(username: $username)
  }
  """
  @me_q """
  query Test {
    me {
      user { #{@user_basics} }
      #{@me_basics}
    }
  }
  """
  @create_q """
  mutation Test($user: RegistrationInput!) {
    createUser(user: $user) {
      user { #{@user_basics} }
      #{@me_basics}
    }
  }
  """
  @update_q """
  mutation Test($profile: UpdateProfileInput!) {
    updateProfile(profile: $profile) {
      user { #{@user_basics} }
      #{@me_basics}
    }
  }
  """
  @reset_request_q """
  mutation Test($email: String!) {
    resetPasswordRequest(email: $email)
  }
  """
  @reset_q """
  mutation Test($token: String!, $password: String!) {
    resetPassword(token: $token, password: $password) {
      __typename
      token
      me {
        user { #{@user_basics} }
        #{@me_basics}
      }
    }
  }
  """
  @confirm_q """
  mutation Test($token: String!) {
    confirmEmail(token: $token) {
      __typename
      token
      me {
        user { #{@user_basics} }
        #{@me_basics}
      }
    }
  }
  """
  @login_q """
  mutation Test($email: String!, $password: String!) {
    createSession(email: $email, password: $password) {
      __typename
      token
      me {
        user { #{@user_basics} }
        #{@me_basics}
      }
    }
  }
  """
  @logout_q """
  mutation Test {
    deleteSession
  }
  """
  @delete_q """
  mutation Test {
    deleteSelf(iAmSure: true)
  }
  """
  describe "activities.user" do
  end

  describe "me" do
    test "works" do
      vars = %{}
      query = %{query: @me_q, variables: vars, operationName: "Test"}
      assert %{"me" => me} = gql_post_data(json_conn(), query)
      assert_me(me)
    end
  end
  describe "username_available" do
    test "works" do
      vars = %{"username" => ""}
      query = %{query: @username_available_q, variables: vars, operationName: "Test"}
      assert %{"usernameAvailable" => av} = gql_post_data(json_conn(), query)
      assert is_boolean(av)
    end
  end
  describe "create_user" do
    test "works" do
      vars = %{"user" => Fake.registration_input()}
      query = %{query: @create_q, variables: vars, operationName: "Test"}
      assert %{"createUser" => me} = gql_post_data(json_conn(), query)
      assert_me(me)
    end
  end
  describe "update_profile" do
    test "works" do
      vars = %{"profile" => Fake.profile_update_input()}
      query = %{query: @update_q, variables: vars, operationName: "Test"}
      assert %{"updateProfile" => me} = gql_post_data(json_conn(), query)
      assert_me(me)
    end
  end
  describe "reset_request" do
    test "works" do
      vars = %{"email" => ""}
      query = %{query: @reset_request_q, variables: vars, operationName: "Test"}
      assert %{"resetPasswordRequest" => true} = gql_post_data(json_conn(), query)
    end
  end
  describe "reset" do
    test "works" do
      vars = %{"token" => "", "password" => ""}
      query = %{query: @reset_q, variables: vars, operationName: "Test"}
      assert %{"resetPassword" => auth} = gql_post_data(json_conn(), query)
      assert_auth_payload(auth)
    end
  end
  describe "confirm" do
    test "works" do
      vars = %{"token" => ""}
      query = %{query: @confirm_q, variables: vars, operationName: "Test"}
      assert %{"confirmEmail" => auth} = gql_post_data(json_conn(), query)
      assert_auth_payload(auth)
    end
  end
  describe "login" do
    test "works" do
      vars = %{"email" => "", "password" => ""}
      query = %{query: @login_q, variables: vars, operationName: "Test"}
      assert %{"createSession" => auth} = gql_post_data(json_conn(), query)
      assert_auth_payload(auth)
    end
  end
  describe "logout" do
    test "works" do
      vars = %{}
      query = %{query: @logout_q, variables: vars, operationName: "Test"}
      assert %{"deleteSession" => true} = gql_post_data(json_conn(), query)
    end
  end
  describe "delete" do
    test "works" do
      vars = %{"iAmSure" => true}
      query = %{query: @delete_q, variables: vars, operationName: "Test"}
      assert %{"deleteSelf" => true} = gql_post_data(json_conn(), query)
    end
  end

  describe "my_follow" do

    test "collection" do
      q = """
      query Test {
        collection(collectionId: "") {
          myFollow {
            id canonicalUrl isLocal isPublic createdAt __typename
          }
        }
      }
      """
      query = %{query: q, operationName: "Test"}
      assert %{"collection" => coll} = gql_post_data(json_conn(), query)
      assert %{"myFollow" => follow} = coll
      assert_follow(follow)
    end

    test "community" do
      q = """
      query Test {
        community(communityId: "") {
          myFollow {
            id canonicalUrl isLocal isPublic createdAt __typename
          }
        }
      }
      """
      query = %{query: q, operationName: "Test"}
      assert %{"community" => comm} = gql_post_data(json_conn(), query)
      assert %{"myFollow" => follow} = comm
      assert_follow(follow)
    end

    test "thread" do
      q = """
      query Test {
        thread(threadId: "") {
          myFollow {
            id canonicalUrl isLocal isPublic createdAt __typename
          }
        }
      }
      """
      query = %{query: q, operationName: "Test"}
      assert %{"thread" => thread} = gql_post_data(json_conn(), query)
      assert %{"myFollow" => follow} = thread
      assert_follow(follow)
    end

    test "user" do
      q = """
      query Test {
        user(userId: "") {
          myFollow {
            id canonicalUrl isLocal isPublic createdAt __typename
          }
          #{@user_basics}
        }
      }
      """
      query = %{query: q, operationName: "Test"}
      assert %{"user" => user} = gql_post_data(json_conn(), query)
      assert %{"myFollow" => follow} = user
      assert_user(user)
      assert_follow(follow)
    end

  end

  describe "my_like" do

    test "user" do
      q = """
      query Test {
        user(userId: "") {
          myLike {
            id canonicalUrl isLocal isPublic createdAt __typename
          }
          #{@user_basics}
        }
      }
      """
      query = %{query: q, operationName: "Test"}
      assert %{"user" => user} = gql_post_data(json_conn(), query)
      assert %{"myLike" => like} = user
      assert_user(user)
      assert_like(like)
    end

    test "collection" do
      q = """
      query Test {
        collection(collectionId: "") {
          myLike {
            id canonicalUrl isLocal isPublic createdAt __typename
          }
          #{@collection_basics}
        }
      }
      """
      query = %{query: q, operationName: "Test"}
      assert %{"collection" => collection} = gql_post_data(json_conn(), query)
      assert %{"myLike" => like} = collection
      assert_collection(collection)
      assert_like(like)
    end

    test "resource" do
      q = """
      query Test {
        resource(resourceId: "") {
          myLike {
            id canonicalUrl isLocal isPublic createdAt __typename
          }
          #{@resource_basics}
        }
      }
      """
      query = %{query: q, operationName: "Test"}
      assert %{"resource" => resource} = gql_post_data(json_conn(), query)
      assert %{"myLike" => like} = resource
      assert_resource(resource)
      assert_like(like)
    end

    test "comment" do
      q = """
      query Test {
        comment(commentId: "") {
          myLike {
            id canonicalUrl isLocal isPublic createdAt __typename
          }
          #{@comment_basics}
        }
      }
      """
      query = %{query: q, operationName: "Test"}
      assert %{"comment" => comment} = gql_post_data(json_conn(), query)
      assert %{"myLike" => like} = comment
      assert_comment(comment)
      assert_like(like)
    end

  end

  # @user_basic_fields "id local preferredUsername name summary location website icon image"
  # @primary_language "primaryLanguage { id }"

  # describe "UsersResolver.username_available" do
  #   test "works for a guest" do
  #     query = "{ usernameAvailable(username: \"#{Fake.preferred_username()}\") }"
  #     assert true == Map.fetch!(gql_post_data(%{query: query}), "usernameAvailable")

  #     actor = fake_actor!()
  #     query = "{ usernameAvailable(username: \"#{actor.preferred_username}\") }"
  #     assert false == Map.fetch!(gql_post_data(%{query: query}), "usernameAvailable")
  #   end

  #   test "works for a logged in user" do
  #     user = fake_user!()
  #     {:ok, actor} = Actors.fetch_by_alias(user.id)
  #     conn = user_conn(user)
  #     query = "{ usernameAvailable(username: \"#{Fake.preferred_username()}\") }"
  #     assert true == Map.fetch!(gql_post_data(conn, %{query: query}), "usernameAvailable")

  #     query = "{ usernameAvailable(username: \"#{actor.preferred_username}\") }"
  #     assert false == Map.fetch!(gql_post_data(conn, %{query: query}), "usernameAvailable")
  #   end
  # end

  # describe "UsersResolver.me" do
  #   test "Works for a logged in user" do
  #     user = fake_user!()
  #     conn = user_conn(user)
  #     query = "{ me { email user { #{@user_basic_fields} #{@primary_language} } } }"

  #     assert %{"email" => email, "user" => user2} =
  #              Map.fetch!(gql_post_data(conn, %{query: query}), "me")
  #     assert user.email == email
  #     assert %{"id" => id, "preferredUsername" => preferred_username} = user2
  #     assert user.actor.id == id
  #     assert user.actor.preferred_username == preferred_username
  #     assert %{"name" => name, "summary" => summary} = user2
  #     assert user.actor.current.name == name
  #     assert user.actor.current.summary == summary
  #     # assert %{"location" => location, "website" => website} = user2
  #     # assert user.actor.current.location == user2["location"]
  #     # assert user.actor.current.website == user2["website"]
  #     assert %{"icon" => icon, "image" => image} = user2
  #     assert user.actor.current.icon == icon
  #     assert user.actor.current.image == image
  #     # assert user.actor.current.primary_language == user2["primaryLanguage"]["id"]
  #   end

  #   test "Does not work for a guest" do
  #     query = "{ me { email user { #{@user_basic_fields} }} }"
  #     assert_not_logged_in(gql_post_errors(%{query: query}), ["me"])
  #   end
  # end

  # describe "UsersResolver.user" do

  #   test "Works for a logged in user" do
  #     user = fake_user!(%{is_public: true})
  #     conn = user_conn(user)
  #     query = "{ user(userId: \"#{user.actor.id}\") { #{@user_basic_fields} } }"
  #     user2 = Map.fetch!(gql_post_data(conn, %{query: query}), "user")
  #     assert %{"id" => id, "preferredUsername" => preferred_username} = user2
  #     assert user.actor.id == id
  #     assert user.actor.preferred_username == preferred_username
  #     assert %{"name" => name, "summary" => summary} = user2
  #     assert user.actor.current.name == name
  #     assert user.actor.current.summary == summary
  #     # assert %{"location" => location, "website" => website} = user2
  #     # assert user.actor.current.location == user2["location"]
  #     # assert user.actor.current.website == user2["website"]
  #     assert %{"icon" => icon, "image" => image} = user2
  #     assert user.actor.current.icon == icon
  #     assert user.actor.current.image == image
  #     # assert user.actor.current.primary_language == user2["primaryLanguage"]
  #   end

  #   test "Works for a guest" do
  #     user = fake_user!()
  #     query = "{ user(userId: \"#{user.actor.id}\") { #{@user_basic_fields} } }"
  #     user2 = Map.fetch!(gql_post_data(json_conn(), %{query: query}), "user")
  #     assert %{"id" => id, "preferredUsername" => preferred_username} = user2
  #     assert user.actor.id == id
  #     assert user.actor.preferred_username == preferred_username
  #     assert %{"name" => name, "summary" => summary} = user2
  #     assert user.actor.current.name == name
  #     assert user.actor.current.summary == summary
  #     # assert %{"location" => location, "website" => website} = user2
  #     # assert user.actor.current.location == user2["location"]
  #     # assert user.actor.current.website == user2["website"]
  #     assert %{"icon" => icon, "image" => image} = user2
  #     assert user.actor.current.icon == icon
  #     assert user.actor.current.image == image
  #     # assert user.actor.current.primary_language == user2["primaryLanguage"]
  #   end

  #   @tag :skip
  #   @todo_when :post_moot
  #   test "Does not work for a user that is not public" do
  #     user = fake_user!(%{is_public: false})
  #     conn = user_conn(user)
  #     query = "{ user(userId: \"#{user.actor.id}\") { #{@user_basic_fields} }}"
  #     # TODO: ensure this is correct, we may want unauthorized
  #     assert_not_found(gql_post_errors(conn, %{query: query}), ["user"])
  #   end
  # end

  # describe "UsersResolver.create_user" do
  #   test "Works for a guest with good inputs" do
  #     reg = Fake.registration_input()
  #     assert {:ok, _} = Access.create_register_email(reg["email"])

  #     query = """
  #     mutation Test($user: RegistrationInput) {
  #       createUser(user:$user) {
  #         me { email user { #{@user_basic_fields} } }
  #       }
  #     }
  #     """

  #     query = %{operationName: "Test", query: query, variables: %{"user" => reg}}
  #     Map.fetch!(gql_post_data(json_conn(), query), "createUser")
  #   end

  #   test "Does not work for a logged in user" do
  #     reg = Fake.registration_input()
  #     assert {:ok, _} = Access.create_register_email(reg["email"])

  #     query = """
  #       mutation Test($user: RegistrationInput) {
  #         createUser(user:$user) {
  #           me { email user { #{@user_basic_fields} } }
  #         }
  #       }
  #     """

  #     query = %{operationName: "Test", query: query, variables: %{"user" => reg}}
  #     user = fake_user!()
  #     conn = user_conn(user)
  #     assert_not_permitted(gql_post_errors(conn, query), ["createUser"])
  #   end

  #   @tag :skip
  #   @todo :changeset_errors
  #   test "Does not work for a taken preferred username" do
  #     user = fake_user!()
  #     reg = Fake.registration_input(%{"preferredUsername" => user.actor.preferred_username})
  #     assert {:ok, _} = Access.create_register_email(reg["email"])

  #     query = """
  #       mutation Test($user: RegistrationInput) {
  #         createUser(user:$user) {
  #           me { email user { #{@user_basic_fields} } }
  #         }
  #       }
  #     """

  #     query = %{operationName: "Test", query: query, variables: %{"user" => reg}}
  #     assert err = Map.fetch!(gql_post_errors(json_conn(), query), ["createUser"])
  #   end

  #   @tag :skip
  #   @todo :changeset_errors
  #   test "Does not work for a taken email" do
  #     user = fake_user!()
  #     reg = Fake.registration_input(%{"email" => user.email})
  #     assert {:ok, _} = Access.create_register_email(reg["email"])

  #     query = """
  #       mutation Test($user: RegistrationInput) {
  #         createUser(user:$user) {
  #           me { email user { #{@user_basic_fields} } }
  #         }
  #       }
  #     """

  #     query = %{operationName: "Test", query: query, variables: %{"user" => reg}}
  #     assert err = Map.fetch!(gql_post_errors(json_conn(), query), ["createUser"])
  #   end
  # end

  # describe "UsersResolver.update_profile" do

  #   test "Works for a logged in user" do
  #     user = fake_user!()
  #     conn = user_conn(user)

  #     query = %{
  #       query: """
  #       mutation Test($profile: UpdateProfileInput!) {
  #         updateProfile(profile: $profile) {
  #           user { #{@user_basic_fields} }
  #         }
  #       }
  #       """,
  #       operationName: "Test",
  #       variables: %{"profile" => Fake.profile_update_input()}
  #     }

  #     assert data = gql_post_data(conn, query)["updateProfile"]
  #     assert MapSet.new(Map.keys(data["user"])) == MapSet.new(String.split(@user_basic_fields))
  #   end

  #   test "Does not work for a guest" do
  #     query = %{
  #       query: """
  #       mutation Test($profile: UpdateProfileInput!) {
  #         updateProfile(profile: $profile) {
  #           user { #{@user_basic_fields} }
  #         }
  #       }
  #       """,
  #       operationName: "Test",
  #       variables: %{"profile" => Fake.profile_update_input()}
  #     }

  #     assert_not_logged_in(gql_post_errors(query), ["updateProfile"])
  #   end
  # end

  # describe "UsersResolver.delete_user" do

  #   test "Works for a logged in user" do
  #     user = fake_user!()
  #     conn = user_conn(user)
  #     query = "mutation { deleteUser }"
  #     assert conn |> gql_post_data(%{query: query}) |> Map.get("deleteUser")
  #     assert {:error, e} = Users.fetch(user.id)
  #     assert {:error, e} = Actors.fetch(user.actor.id)
  #   end

  #   test "Does not work for a guest" do
  #     query = "mutation { deleteUser }"
  #     assert_not_logged_in(gql_post_errors(%{query: query}), ["deleteUser"])
  #   end

  # end

  # describe "UsersResolver.reset_password_request" do

  #   test "Works for a guest" do
  #     user = fake_user!()
  #     query = "mutation { resetPasswordRequest(email: \"#{user.email}\") }"
  #     assert true == gql_post_data(%{query: query}) |> Map.get("resetPasswordRequest")
  #     # TODO: check that an email is sent
  #   end

  #   test "Does not work for a user" do
  #     user = fake_user!()
  #     conn = user_conn(user)
  #     query = "mutation { resetPasswordRequest(email: \"#{user.email}\") }"
  #     assert_not_permitted(gql_post_errors(conn, %{query: query}), ["resetPasswordRequest"])
  #     # TODO: check that an email is sent
  #   end

  #   test "Does not work for an invalid email" do
  #     query = "mutation { resetPasswordRequest(email: \"#{Fake.email()}\") }"
  #     assert_not_found(gql_post_errors(%{query: query}), ["resetPasswordRequest"])
  #   end

  # end

  # describe "UsersResolver.reset_password" do
  #   test "Works for a guest with a valid token" do
  #     user = fake_user!()
  #     assert {:ok, %{id: token}} = Users.request_password_reset(user)

  #     query = "mutation { resetPassword(token: \"#{token}\", password: \"password\") }"
  #     assert %{query: query} |> gql_post_data() |> Map.get("resetPassword")
  #   end

  #   test "Does not work for a user" do
  #     query = "mutation { resetPassword(token: \"#{Fake.uuid()}\", password: \"password\") }"
  #     assert_not_found(gql_post_errors(%{query: query}), ["resetPassword"])
  #   end
  # end

  # describe "UsersResolver.confirm_email" do
  #   test "Works for a guest with a valid token" do
  #     user = fake_user!()
  #     [token] = user.email_confirm_tokens
  #     query = "mutation { confirmEmail(token: \"#{token.id}\") }"

  #     assert true == Map.fetch!(gql_post_data(%{query: query}), "confirmEmail")
  #   end

  #   test "Works with an authenticated user" do
  #     user = fake_user!()
  #     [token] = user.email_confirm_tokens
  #     query = "mutation { confirmEmail(token: \"#{token.id}\") }"

  #     assert true == Map.fetch!(gql_post_data(%{query: query}), "confirmEmail")
  #   end

  #   test "Fails with an invalid token" do
  #     query = "mutation { confirmEmail(token: \"#{Faker.UUID.v4()}\") }"
  #     assert_not_found(gql_post_errors(%{query: query}), ["confirmEmail"])
  #   end
  # end

  # describe "UsersResolver.create_session" do
  #   test "Works with a valid email and password" do
  #     user = fake_user!(%{password: "password"})

  #     query = """
  #     mutation {
  #       createSession(email: \"#{user.email}\", password: \"password\") {
  #         token
  #         me {
  #           email
  #         }
  #       }
  #     }
  #     """

  #     assert resp = %{query: query} |> gql_post_data() |> Map.get("createSession")
  #     assert is_binary(resp["token"])
  #     assert resp["me"]["email"] == user.email
  #   end

  #   test "Does not work for a missing email" do
  #     query = """
  #     mutation {
  #       createSession(email: \"#{Fake.email()}\", password: \"#{Fake.password()}\") {
  #         token
  #       }
  #     }
  #     """

  #     assert_not_permitted(gql_post_errors(%{query: query}), ["createSession"])
  #   end

  #   test "Does not work with an invalid password" do
  #     user = fake_user!()

  #     query = """
  #     mutation {
  #       createSession(email: \"#{user.email}\", password: \"invalid\") {
  #         token
  #       }
  #     }
  #     """

  #     assert_not_permitted(gql_post_errors(%{query: query}), ["createSession"])
  #   end
  # end

  # describe "UsersResolver.delete_session" do
  #   test "Works with a logged in user" do
  #     user = fake_user!(%{password: "password"})
  #     assert {:ok, _} = OAuth.create_token(user, "password")

  #     conn = user_conn(user)
  #     query = "mutation { deleteSession }"
  #     assert conn |> gql_post_data(%{query: query}) |> Map.get("deleteSession")
  #   end

  #   test "Does not work for a guest" do
  #     query = "mutation { deleteSession }"
  #     assert_not_logged_in(gql_post_errors(%{query: query}), ["deleteSession"])
  #   end
  # end

  # describe "UsersResolver.check_username_available" do

  #   test "works for an available username" do
  #     name = Fake.preferred_username()
  #     query = "{ usernameAvailable(username: \"#{name}\") }"
  #     assert true == Map.fetch!(gql_post_data(%{query: query}), "usernameAvailable")
  #   end

  #   test "works for an unavailable username" do
  #     user = fake_user!()
  #     query = "{ usernameAvailable(username: \"#{user.actor.preferred_username}\") }"
  #     assert false == Map.fetch!(gql_post_data(%{query: query}), "usernameAvailable")
  #   end

  # end

end
