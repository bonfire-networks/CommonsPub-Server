# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.OAuthTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking
  alias MoodleNet.Access
  alias MoodleNet.Common.NotFoundError
  alias MoodleNet.Access.{
    Token,
    TokenExpiredError,
    TokenNotFoundError,
    UserDisabledError,
    UserEmailNotConfirmedError,
  }

  defp strip(user), do: Map.drop(user, [:actor, :email_confirm_tokens, :auth, :user])

  describe "MoodleNet.OAuth.fetch_token_and_user/1" do

    test "works" do
      user = fake_user!(%{}, confirm_email: true)
      token = fake_token!(user)
      assert token.user_id == user.id
      assert {:ok, {token2, user2}} = Access.fetch_token_and_user(token.id)
      assert strip(token) == strip(token2)
      assert strip(user) == strip(user2)
    end

    test "fails with an invalid token" do
      user = fake_user!(%{}, confirm_email: true)
      token = fake_token!(user)
      assert token.user_id == user.id
      assert {:error, error} = Access.fetch_token_and_user(token.id <> token.id)
      assert %TokenNotFoundError{} == error
    end

  end

  describe "MoodleNet.OAuth.hard_delete/1" do

    test "works with a Token" do
      user = fake_user!(%{}, confirm_email: true)
      token = fake_token!(user)
      {:ok, token2} = Access.hard_delete(token)
      assert deleted(token) == token2
      assert {:error, %NotFoundError{}} = Access.fetch_token_and_user(token.id)
    end

    # test "works with an Authorization" do
    #   user = fake_user!(%{}, confirm_email: true)
    #   assert {:ok, auth} = OAuth.create_auth(user)
    #   assert {:ok, auth2} = OAuth.hard_delete(auth)
    #   assert {:error, %NotFoundError{key: auth.id}} == OAuth.fetch_auth(auth.id)
    # end

  end

  describe "MoodleNet.OAuth.verify_user" do

    test "ok for a valid user" do
      user = fake_user!(%{}, confirm_email: true)
      assert :ok == Access.verify_user(user)
    end

    test "errors for a user without a confirmed email" do
      user = fake_user!(%{}, confirm_email: false)
      assert {:error, %UserEmailNotConfirmedError{}} ==
        Access.verify_user(user)
    end
  end
  
  describe "MoodleNet.OAuth.verify_token" do

    test "ok for a valid token" do
      user = fake_user!(%{}, confirm_email: true)
      token = fake_token!(user)
      assert :ok == Access.verify_token(token)
    end

    test "errors for an expired token" do
      user = fake_user!(%{}, confirm_email: true)
      token = fake_token!(user)
      then = DateTime.add(token.created_at, 3600 * 24 * 15, :second)
      assert {:error, %TokenExpiredError{token: token}} ==
        Access.verify_token(token, then)
    end

  end

end
