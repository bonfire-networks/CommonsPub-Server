# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.Users.MutationsTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNet.Test.Fake
  import MoodleNetWeb.Test.GraphQLAssertions
  import MoodleNetWeb.Test.GraphQLFields
  import MoodleNet.Test.Trendy
  import MoodleNet.Test.Faking
  alias MoodleNet.{Access, Users}

  describe "create_user" do

    test "Works for a guest with good inputs" do
      reg = Fake.registration_input()
      assert {:ok, _} = Access.create_register_email(reg["email"])
      q = create_user_mutation()
      me = gruff_post_key(q, json_conn(), :create_user, %{user: reg})
      assert_me(reg, me)
    end

    test "Does not work for a logged in user" do
      alice = fake_user!()
      reg = Fake.registration_input()
      assert {:ok, _} = Access.create_register_email(reg["email"])
      q = create_user_mutation()
      assert_not_permitted(gruff_post_errors(q, user_conn(alice), %{user: reg}), ["createUser"])
    end

    @tag :skip # returns wrong format on error :/
    test "Does not work for a taken preferred username" do
      alice = fake_user!()
      reg = Fake.registration_input(%{"preferredUsername" => alice.actor.preferred_username})
      assert {:ok, _} = Access.create_register_email(reg["email"])
      q = create_user_mutation()
      gruff_post_errors(q, json_conn(), %{user: reg})
    end

    @tag :skip # returns wrong format on error :/
    test "Does not work for a taken email" do
      alice = fake_user!()
      reg = Fake.registration_input(%{"email" => alice.local_user.email})
      assert {:ok, _} = Access.create_register_email(reg["email"])
      q = create_user_mutation()
      gruff_post_errors(q, json_conn(), %{user: reg})
    end

  end

  describe "update_user" do

    test "Works for a logged in user" do
      alice = fake_user!()
      conn = user_conn(alice)
      profile = Fake.profile_update_input()
      q = update_profile_mutation()
      vars = %{profile: profile}
      me = gruff_post_key(q, conn, :update_profile, vars)
      assert_me(profile, me)
    end

    test "Does not work for a guest" do
      q = update_profile_mutation()
      vars = %{profile: Fake.profile_update_input()}
      assert_not_logged_in(gruff_post_errors(q, json_conn(), vars), ["updateProfile"])
    end

  end

  describe "delete_self" do

    test "Works for a logged in user" do
      alice = fake_user!()
      conn = user_conn(alice)
      q = delete_self_mutation()
      assert true == gruff_post_key(q, conn, :delete_self, %{i_am_sure: true})
    end

    test "Does not work if you are unsure" do
      alice = fake_user!()
      conn = user_conn(alice)
      q = delete_self_mutation()
      gruff_post_errors(q, conn)
    end

    test "Does not work for a guest" do
      q = delete_self_mutation()
      assert_not_logged_in(gruff_post_errors(q, json_conn(), %{i_am_sure: true}), ["deleteSelf"])
    end

  end

  describe "reset_password_request" do

    test "Works for a guest" do
      alice = fake_user!()
      q = reset_password_request_mutation()
      vars = %{email: alice.local_user.email}
      assert true == gruff_post_key(q, json_conn(), :reset_password_request, vars)
      # TODO: check that an email is sent
    end

    test "Does not work for a user" do
      alice = fake_user!()
      conn = user_conn(alice)
      q = reset_password_request_mutation()
      vars = %{email: alice.local_user.email}
      assert_not_permitted(gruff_post_errors(q, conn, vars), ["resetPasswordRequest"])
      # TODO: check that an email is not sent
    end

    test "Does not work for an invalid email" do
      q = reset_password_request_mutation()
      vars = %{email: Fake.email()}
      assert_not_found(gruff_post_errors(q, json_conn(), vars), ["resetPasswordRequest"])
    end

  end

  describe "reset_password" do

    test "Works for a guest with a valid token" do
      alice = fake_user!()
      assert {:ok, %{id: token}} = Users.request_password_reset(alice)
      q = reset_password_mutation()
      vars = %{token: token, password: "password"}
      auth = assert_auth_payload(gruff_post_key(q, json_conn(), :reset_password, vars))
      assert_me(alice, auth.me)
    end

    test "Does not work with a used token" do
      alice = fake_user!()
      assert {:ok, %{id: token}} = Users.request_password_reset(alice)
      q = reset_password_mutation()
      vars = %{token: token, password: "password"}
      auth = assert_auth_payload(gruff_post_key(q, json_conn(), :reset_password, vars))
      assert_me(alice, auth.me)
      gruff_post_errors(q, json_conn(), vars)
    end
    
    test "Does not work for a user" do
      alice = fake_user!()
      conn = user_conn(alice)
      assert {:ok, %{id: token}} = Users.request_password_reset(alice)
      q = reset_password_mutation()
      vars = %{token: token, password: "password"}
      assert_not_permitted(gruff_post_errors(q, conn, vars), ["resetPassword"])
    end

  end

  describe "confirm_email" do

    test "Works for a guest with a valid token" do
      alice = fake_user!()
      [token] = alice.local_user.email_confirm_tokens
      q = confirm_email_mutation()
      vars = %{token: token.id}
      conn = json_conn()
      auth = assert_auth_payload(gruff_post_key(q, conn, :confirm_email, vars))
      assert_me(alice, auth.me)
    end

    test "Does not work with an authenticated user" do
      alice = fake_user!()
      [token] = alice.local_user.email_confirm_tokens
      q = confirm_email_mutation()
      vars = %{token: token.id}
      conn = user_conn(alice)
      assert_not_permitted(gruff_post_errors(q, conn, vars), ["confirmEmail"])
    end

    test "Fails with an invalid token" do
      q = confirm_email_mutation()
      vars = %{token: Fake.uuid()}
      assert_not_found(gruff_post_errors(q, json_conn(), vars), ["confirmEmail"])
    end

  end

  describe "create_session" do

    test "Works with a valid email and password" do
      alice = fake_user!(%{password: "password"},confirm_email: true)
      q = create_session_mutation()
      vars = %{email: alice.local_user.email, password: "password"}
      auth = assert_auth_payload(gruff_post_key(q, json_conn(), :create_session, vars))
      assert_me(alice, auth.me)
    end

    test "Does not work with an unconfirmed email" do
      alice = fake_user!(%{password: "password"}, confirm_email: false)
      q = create_session_mutation()
      vars = %{email: alice.local_user.email, password: "password"}
      gruff_post_errors(q, json_conn(), vars)
    end

  end

  describe "delete_session" do

    test "Works with a logged in user" do
      user = fake_user!(%{password: "password"}, confirm_email: true)
      assert {:ok, token} = Access.create_token(user, "password")
      conn = token_conn(token)
      q = delete_session_mutation()
      assert true == gruff_post_key(q, conn, :delete_session)
    end

    test "Does not work for a guest" do
      q = delete_session_mutation()
      assert_not_logged_in(gruff_post_errors(q, json_conn()), ["deleteSession"])
    end

  end

end
