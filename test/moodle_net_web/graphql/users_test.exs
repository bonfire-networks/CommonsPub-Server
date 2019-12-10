# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.UsersTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNet.Test.Fake
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import MoodleNet.Test.Faking
  alias MoodleNet.{Access, Common, Users}

  describe "usernameAvailable" do
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

  describe "me" do
    test "works for a logged in user" do
      user = fake_user!()
      conn = user_conn(user)
      query = "{ me { #{me_basics()} user { #{user_basics()} } } }"
      assert %{"me" => me} = gql_post_data(conn, %{query: query})
      assert_me(me)
      # assert user.primary_language == user2["primaryLanguage"]["id"]
    end

    test "does not work for a guest" do
      query = "{ me { #{me_basics()} user { #{user_basics()} } } }"
      assert_not_logged_in(gql_post_errors(%{query: query}), ["me"])
    end
  end

  describe "user" do

    test "Works for a logged in user" do
      user = fake_user!(%{is_public: true})
      conn = user_conn(user)
      query = "{ user(userId: \"#{user.id}\") { #{user_basics()} } }"
      assert %{"user" => user2} = gql_post_data(conn, %{query: query})
      assert_user(user, user2)
      # assert user.primary_language == user2["primaryLanguage"]
    end

    test "Works for a guest" do
      user = fake_user!()
      query = "{ user(userId: \"#{user.id}\") { #{user_basics()} } }"
      assert %{"user" => user2} = gql_post_data(json_conn(), %{query: query})
      user2 = assert_user(user, user2)
      # assert user.primary_language == user2["primaryLanguage"]
    end

  #   @tag :skip
  #   @milestone :privacy
  #   test "Does not work for a user that is not public" do
  #     user = fake_user!(%{is_public: false})
  #     conn = user_conn(user)
  #     query = "{ user(userId: \"#{user.id}\") { #{user_basics()} }}"
  #     # TODO: ensure this is correct, we may want unauthorized
  #     assert_not_found(gql_post_errors(conn, %{query: query}), ["user"])
  #   end

  #   @tag :skip
  #   @milestone :privacy
  #   test "Works for self when not public" do
  #   end

  end

  describe "createUser" do
    test "Works for a guest with good inputs" do
      reg = Fake.registration_input()
      assert {:ok, _} = Access.create_register_email(reg["email"])

      query = """
      mutation Test($user: RegistrationInput) {
        createUser(user:$user) { #{me_basics()} user { #{user_basics()} } }
      }
      """

      query = %{operationName: "Test", query: query, variables: %{"user" => reg}}
      assert %{"createUser" => create_user} = gql_post_data(json_conn(), query)
      me = assert_me(create_user)
      assert reg["email"] == me.email
      assert reg["wantsEmailDigest"] == me.wants_email_digest
      assert reg["wantsNotifications"] == me.wants_notifications
      assert reg["preferredUsername"] == me.user.preferred_username
      assert reg["name"] == me.user.name
      assert reg["summary"] == me.user.summary
      assert reg["location"] == me.user.location
      assert reg["website"] == me.user.website
      assert reg["icon"] == me.user.icon
      assert reg["image"] == me.user.image
      assert me.user.is_local == true
      assert me.user.is_public == true
      assert me.user.is_disabled == false
      assert me.is_confirmed == false
      assert me.is_instance_admin == false
    end

    test "Does not work for a logged in user" do
      reg = Fake.registration_input()
      assert {:ok, _} = Access.create_register_email(reg["email"])

      query = """
        mutation Test($user: RegistrationInput) {
          createUser(user:$user) { #{me_basics()} user { #{user_basics()} }  }
        }
      """

      query = %{operationName: "Test", query: query, variables: %{"user" => reg}}
      user = fake_user!()
      conn = user_conn(user)
      assert_not_permitted(gql_post_errors(conn, query), ["createUser"])
    end

    @tag :skip
    @todo :changeset_errors
    test "Does not work for a taken preferred username" do
      user = fake_user!()
      reg = Fake.registration_input(%{"preferredUsername" => user.actor.preferred_username})
      assert {:ok, _} = Access.create_register_email(reg["email"])

      query = """
        mutation Test($user: RegistrationInput) {
          createUser(user:$user) {
            me { #{me_basics()} user { #{user_basics()} }  }
          }
        }
      """

      query = %{operationName: "Test", query: query, variables: %{"user" => reg}}
      assert err = Map.fetch!(gql_post_errors(json_conn(), query), ["createUser"])
    end

    @tag :skip
    @todo :changeset_errors
    test "Does not work for a taken email" do
      user = fake_user!()
      reg = Fake.registration_input(%{"email" => user.local_user.email})
      assert {:ok, _} = Access.create_register_email(reg["email"])

      query = """
        mutation Test($user: RegistrationInput) {
          createUser(user:$user) {
            me { email user { #{user_basics()} } }
          }
        }
      """

      query = %{operationName: "Test", query: query, variables: %{"user" => reg}}
      assert err = Map.fetch!(gql_post_errors(json_conn(), query), ["createUser"])
    end

  end

  describe "updateProfile" do

    test "Works for a logged in user" do
      user = fake_user!()
      conn = user_conn(user)
      profile = Fake.profile_update_input()
      q = """
      mutation Test($profile: UpdateProfileInput!) {
        updateProfile(profile: $profile) {
          #{me_basics()} user { #{user_basics()} }
        }
      }
      """
      query = %{query: q, operationName: "Test", variables: %{"profile" => profile}}
      assert %{"updateProfile" => me} = gql_post_data(conn, query)
      me = assert_me(me)
      assert profile["wantsEmailDigest"] == me.wants_email_digest
      assert profile["wantsNotifications"] == me.wants_notifications
      assert profile["name"] == me.user.name
      assert profile["summary"] == me.user.summary
      assert profile["location"] == me.user.location
      assert profile["website"] == me.user.website
      assert profile["icon"] == me.user.icon
      assert profile["image"] == me.user.image
      assert me.user.is_local == true
      assert me.user.is_public == true
      assert me.user.is_disabled == false
      assert me.is_confirmed == false
      assert me.is_instance_admin == false
    end

    test "Does not work for a guest" do
      query = %{
        query: """
        mutation Test($profile: UpdateProfileInput!) {
          updateProfile(profile: $profile) {
            user { #{user_basics()} }
          }
        }
        """,
        operationName: "Test",
        variables: %{"profile" => Fake.profile_update_input()}
      }

      assert_not_logged_in(gql_post_errors(query), ["updateProfile"])
    end
  end

  describe "deleteSelf" do

    test "Works for a logged in user" do
      user = fake_user!()
      conn = user_conn(user)
      query = "mutation { deleteSelf(iAmSure: true) }"
      assert %{"deleteSelf" => true} == gql_post_data(conn, %{query: query})
      assert {:error, e} = Users.fetch(user.id)
    end

    test "Does not work if you are unsure" do
      user = fake_user!()
      conn = user_conn(user)
      query = "mutation { deleteSelf(iAmSure: false) }"
      assert err = gql_post_errors(conn, %{query: query})
    end

    test "Does not work for a guest" do
      query = "mutation { deleteSelf(iAmSure: true) }"
      assert_not_logged_in(gql_post_errors(%{query: query}), ["deleteSelf"])
    end

  end

  describe "resetPasswordRequest" do

    test "Works for a guest" do
      user = fake_user!()
      q = """
      mutation Test { resetPasswordRequest(email: "#{user.local_user.email}") }
      """
      query = %{query: q, operationName: "Test"}
      assert %{"resetPasswordRequest" => true} == gql_post_data(query)
      # TODO: check that an email is sent
    end

    test "Does not work for a user" do
      user = fake_user!()
      conn = user_conn(user)
      query = """
      mutation { resetPasswordRequest(email: "#{user.local_user.email}") }
      """
      assert_not_permitted(gql_post_errors(conn, %{query: query}), ["resetPasswordRequest"])
      # TODO: check that an email is sent
    end

    test "Does not work for an invalid email" do
      query = "mutation { resetPasswordRequest(email: \"#{Fake.email()}\") }"
      assert_not_found(gql_post_errors(%{query: query}), ["resetPasswordRequest"])
    end

  end

  describe "UsersResolver.reset_password" do
    test "Works for a guest with a valid token" do
      user = fake_user!()
      assert {:ok, %{id: token}} = Users.request_password_reset(user)
      q = """
      mutation Test {
        resetPassword(token: "#{token}", password: "password") {
          token me { #{me_basics()} user { #{user_basics()} } }
        }
      }
      """
      query = %{query: q, operationName: "Test"}
      assert %{"resetPassword" => auth} = gql_post_data(query)
      assert %{"token" => token, "me" => me} = auth
      assert is_binary(token)
      assert_me(user, me)
    end

    test "Does not work with a used token" do
      user = fake_user!()
      assert {:ok, %{id: token}} = Users.request_password_reset(user)
      q = """
      mutation Test {
        resetPassword(token: "#{token}", password: "password") {
          token me { #{me_basics()} user { #{user_basics()} } }
        }
      }
      """
      query = %{query: q, operationName: "Test"}
      assert %{"resetPassword" => auth} = gql_post_data(query)
      assert %{"token" => token, "me" => me} = auth
      assert is_binary(token)
      assert_me(user, me)
      assert err = gql_post_errors(query)
    end
    
    test "Does not work for a user" do
      q = """
      mutation Test {
        resetPassword(token: "#{Fake.uuid()}", password: "password") {
          token me { #{me_basics()} user { #{user_basics()} } }
        }
      }
      """
      query = %{query: q, operationName: "Test"}
      assert_not_found(gql_post_errors(query), ["resetPassword"])
    end
  end

  describe "UsersResolver.confirm_email" do
    test "Works for a guest with a valid token" do
      user = fake_user!()
      [token] = user.email_confirm_tokens
      query = """
      mutation {
        confirmEmail(token: "#{token.id}") {
          token me { #{me_basics()} user { #{user_basics()} } }
        }
      }
      """
      assert %{"confirmEmail" => auth} = gql_post_data(%{query: query})
      assert %{"token" => token, "me" => me} = auth
      assert is_binary(token)
      assert_me(user, me)
    end

    test "Works with an authenticated user" do
      user = fake_user!()
      [token] = user.email_confirm_tokens
      query = """
      mutation {
        confirmEmail(token: "#{token.id}") {
        token me { #{me_basics()} user { #{user_basics()} } }
        }
      }
      """
      assert %{"confirmEmail" => auth} = gql_post_data(%{query: query})
      assert %{"token" => token, "me" => me} = auth
      assert is_binary(token)
      assert_me(user, me)
    end

    test "Fails with an invalid token" do
      query = "mutation { confirmEmail(token: \"#{Faker.UUID.v4()}\") { token } }"
      assert_not_found(gql_post_errors(%{query: query}), ["confirmEmail"])
    end
  end

  describe "UsersResolver.create_session" do

    test "Works with a valid email and password" do
      user = fake_user!(%{password: "password"},confirm_email: true)

      query = """
      mutation {
        createSession(email: \"#{user.local_user.email}\", password: \"password\") {
          token
          me { #{me_basics()} user { #{user_basics()} } }
        }
      }
      """

      assert %{"createSession" => auth} = gql_post_data(%{query: query})
      assert %{"token" => token, "me" => me} = auth
      assert is_binary(token)
      assert_me(user, me)
    end

    test "Does not work with an unconfirmed email" do
      user = fake_user!(%{password: "password"})

      query = """
      mutation {
        createSession(email: \"#{user.local_user.email}\", password: \"password\") {
          token
          me { #{me_basics()} user { #{user_basics()} } }
        }
      }
      """

      assert err = gql_post_errors(%{query: query})
    end

    test "Does not work for a missing email" do
      query = """
      mutation {
        createSession(email: "#{Fake.email()}", password: "#{Fake.password()}") {
          token
        }
      }
      """

      assert_invalid_credential(gql_post_errors(%{query: query}), ["createSession"])
    end

    test "Does not work with an invalid password" do
      user = fake_user!()

      query = """
      mutation {
        createSession(email: "#{user.local_user.email}", password: "invalid") {
          token
        }
      }
      """

      assert_invalid_credential(gql_post_errors(%{query: query}), ["createSession"])
    end
  end

  describe "UsersResolver.delete_session" do
    test "Works with a logged in user" do
      user = fake_user!(%{password: "password"}, confirm_email: true)
      assert {:ok, _} = Access.create_token(user, "password")

      conn = user_conn(user)
      query = "mutation { deleteSession }"
      assert %{"deleteSession" => true} = gql_post_data(conn, %{query: query})
    end

    test "Does not work for a guest" do
      query = "mutation { deleteSession }"
      assert_not_logged_in(gql_post_errors(%{query: query}), ["deleteSession"])
    end
  end
  
  describe "delete (via common)" do
    @tag :skip
    test "placeholder" do
    end
  end

  describe "lastActivity" do
    @tag :skip
    @todo :worker
    test "placeholder" do
    end
  end

  describe "myFollow" do
    test "works for guest" do
      alice = fake_user!()
      query = """
      { user(userId: "#{alice.id}") {
          #{user_basics()}
          myFollow { #{follow_basics()} }
        }
      }
      """
      assert %{"user" => user} = gql_post_data(%{query: query})
      user = assert_user(alice, user)
      assert %{"myFollow" => nil} = user
    end
    test "works for user - followd" do
      alice = fake_user!()
      bob = fake_user!()
      {:ok, follow} = Common.follow(bob, alice, %{is_local: true})
      query = """
      { user(userId: "#{alice.id}") {
          #{user_basics()}
          myFollow { #{follow_basics()} }
        }
      }
      """
      conn = user_conn(bob)
      assert %{"user" => user} = gql_post_data(conn, %{query: query})
      user = assert_user(alice, user)
      assert %{"myFollow" => follow2} = user
      assert_follow(follow,follow2)
    end
    test "works for user - unfollowd" do
      alice = fake_user!()
      bob = fake_user!()
      query = """
      { user(userId: "#{alice.id}") {
          #{user_basics()}
          myFollow { #{follow_basics()} }
        }
      }
      """
      conn = user_conn(bob)
      assert %{"user" => user} = gql_post_data(conn, %{query: query})
      user = assert_user(alice, user)
      assert %{"myFollow" => nil} = user
    end
  end

  describe "myLike" do
    test "works for guest" do
      alice = fake_user!()
      query = """
      { user(userId: "#{alice.id}") {
          #{user_basics()}
          myLike { #{like_basics()} }
        }
      }
      """
      assert %{"user" => user} = gql_post_data(%{query: query})
      user = assert_user(alice, user)
      assert %{"myLike" => nil} = user
    end
    test "works for user - liked" do
      alice = fake_user!()
      bob = fake_user!()
      {:ok, like} = Common.like(bob, alice, %{is_local: true})
      query = """
      { user(userId: "#{alice.id}") {
          #{user_basics()}
          myLike { #{like_basics()} }
        }
      }
      """
      conn = user_conn(bob)
      assert %{"user" => user} = gql_post_data(conn, %{query: query})
      user = assert_user(alice, user)
      assert %{"myLike" => like2} = user
      assert_like(like,like2)
    end
    test "works for user - unliked" do
      alice = fake_user!()
      bob = fake_user!()
      query = """
      { user(userId: "#{alice.id}") {
          #{user_basics()}
          myLike { #{like_basics()} }
        }
      }
      """
      conn = user_conn(bob)
      assert %{"user" => user} = gql_post_data(conn, %{query: query})
      user = assert_user(alice, user)
      assert %{"myLike" => nil} = user
    end
  end

  describe "followedCommunities" do
    test "works for guest" do
      alice = fake_user!()
      bob = fake_community!(alice)
      celia = fake_community!(alice)
      {:ok, bob_follow} = Common.follow(alice, bob, %{is_local: true})
      {:ok, celia_follow} = Common.follow(alice, celia, %{is_local: true})
      query = """
      { user(userId: "#{alice.id}") {
          #{user_basics()}
          followedCommunities {
            #{page_basics()}
            edges {
              cursor
              node {
                follow { #{follow_basics()} }
                community { #{community_basics()} }
              }
            }
          }
        }
      }
      """
      assert %{"user" => user} = gql_post_data(%{query: query})
      user = assert_user(alice, user)
      assert %{"followedCommunities" => followeds} = user
      edge_list = assert_edge_list(followeds)
      assert 2 == Enum.count(edge_list.edges)
      for edge <- edge_list.edges do
        assert_follow(edge.node["follow"])
        assert_community(edge.node["community"])
      end
    end
  end

  describe "followedCollections" do
    test "works for guest" do
      alice = fake_user!()
      bob = fake_community!(alice)
      celia = fake_collection!(alice, bob)
      dave = fake_collection!(alice, bob)
      {:ok, celia_follow} = Common.like(alice, celia, %{is_local: true})
      {:ok, dave_follow} = Common.like(alice, dave, %{is_local: true})
      query = """
      { user(userId: "#{alice.id}") {
          #{user_basics()}
          followedCollections {
            #{page_basics()}
            edges {
              cursor
              node {
                follow { #{follow_basics()} }
                collection { #{collection_basics()} }
              }
            }
          }
        }
      }
      """
      assert %{"user" => user} = gql_post_data(%{query: query})
      user = assert_user(alice, user)
      assert %{"followedCollections" => followeds} = user
      edge_list = assert_edge_list(followeds)
      for edge <- edge_list.edges do
        assert_follow(edge["follow"])
        assert_collection(edge["collection"])
      end
    end
  end

  # describe "followedUsers" do
  #   @tag :skip
  #   test "placeholder" do
  #   end
  # end


  describe "likes" do

    test "works for guest" do
      alice = fake_user!()
      bob = fake_user!()
      celia = fake_user!()
      {:ok, bob_like} = Common.like(bob, alice, %{is_local: true})
      {:ok, celia_like} = Common.like(celia, alice, %{is_local: true})
      query = """
      { user(userId: "#{alice.id}") {
          #{user_basics()}
          likes {
            #{page_basics()}
            edges {
              cursor
              node { #{like_basics()} }
            }
          }
        }
      }
      """
      assert %{"user" => user} = gql_post_data(%{query: query})
      user = assert_user(alice, user)
      assert %{"likes" => likes} = user
      edge_list = assert_edge_list(likes)
      # assert Enum.count(likes) == 2
      # for like <- likes do
      #   assert_like(like)
      # end
    end
  end

  describe "comments" do
    @tag :skip
    test "placeholder" do
    end
  end

  describe "inbox" do
    @tag :skip # broken
    test "Works for self" do
      alice = fake_user!()
      bob = fake_user!()
      comm = fake_community!(bob)
      conn = user_conn(alice)
      query = """
      { me {
          #{me_basics()}
          user {
            #{user_basics()}
            inbox { #{page_basics()} edges { cursor node { #{activity_basics()} } } }
          }
        }
      }
      """
      assert %{"me" => me} = gql_post_data(conn, %{query: query})
      me = assert_me(me)
      assert %{"user" => user2} = me
      user2 = assert_user(alice, user2)
      assert %{"inbox" => inbox} = user2
      edge_list = assert_edge_list(inbox)
      assert Enum.count(edge_list.edges) == 1
      for edge <- edge_list.edges do
	activity = assert_activity(edge.node)
	assert is_binary(edge.cursor)
      end
    end
    # test "Does not work for other" do
    # end
    # test "Does not work for guest" do
    # end
  end

  describe "outbox" do

    test "Works for self" do
      user = fake_user!()
      conn = user_conn(user)
      query = """
      { me {
          #{me_basics()}
          user {
            #{user_basics()}
            outbox { #{page_basics()} edges { cursor node { #{activity_basics()} } } }
          }
        }
      }
      """
      assert %{"me" => me} = gql_post_data(conn, %{query: query})
      me = assert_me(me)
      assert %{"user" => user2} = me
      user2 = assert_user(user, user2)
      assert %{"outbox" => outbox} = user2
      edge_list = assert_edge_list(outbox)
      # assert Enum.count(edge_list.edges) == 5
      for edge <- edge_list.edges do
        activity = assert_activity(edge.node)
        assert is_binary(edge.cursor)
      end
    end
  end

end
