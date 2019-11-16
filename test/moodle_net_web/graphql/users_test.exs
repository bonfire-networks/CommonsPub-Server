# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.UsersTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNet.Test.Fake
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import MoodleNet.Test.Faking
  # import MoodleNetWeb.Test.ConnHelpers
  # alias MoodleNet.{Actors, OAuth, Users, Access}

  # @user_basic_fields "id local preferredUsername name summary location website icon image"
  # @primary_language "primaryLanguage { id }"

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
      conn = user_conn(user)
      query = "{ usernameAvailable(username: \"#{Fake.preferred_username()}\") }"
      assert true == Map.fetch!(gql_post_data(conn, %{query: query}), "usernameAvailable")

      query = "{ usernameAvailable(username: \"#{user.actor.preferred_username}\") }"
      assert false == Map.fetch!(gql_post_data(conn, %{query: query}), "usernameAvailable")
    end
  end

  describe "UsersResolver.me" do
    test "works for a logged in user" do
      user = fake_user!()
      conn = user_conn(user)
      query = "{ me { #{me_basics()} user { #{user_basics()} } } }"
      assert data = gql_post_data(conn, %{query: query})
      assert %{"me" => me} = data
      assert %{"email" => email, "user" => user2} = me
      assert user.local_user.email == email
      assert %{"wantsEmailDigest" => wants_digest} =  me
      assert user.local_user.wants_email_digest == wants_digest
      assert %{"wantsNotifications" => wants_notifications} =  me
      assert user.local_user.wants_notifications == wants_notifications
      assert %{"id" => id, "preferredUsername" => preferred_username} = user2
      assert user.id == id
      assert user.actor.preferred_username == preferred_username
      assert %{"name" => name, "summary" => summary} = user2
      assert user.name == name
      assert user.summary == summary
      assert %{"location" => location, "website" => website} = user2
      assert user.location == user2["location"]
      assert user.website == user2["website"]
      assert %{"icon" => icon, "image" => image} = user2
      assert user.icon == icon
      assert user.image == image
      # assert user.primary_language == user2["primaryLanguage"]["id"]
    end

    test "does not work for a guest" do
      query = "{ me { #{me_basics()} user { #{user_basics()} } } }"
      assert_not_logged_in(gql_post_errors(%{query: query}), ["me"])
    end
  end

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
