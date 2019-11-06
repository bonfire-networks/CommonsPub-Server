# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.OAuthTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking
  alias MoodleNet.Common.NotFoundError
  alias MoodleNet.OAuth
  alias MoodleNet.OAuth.{
    AuthorizationAlreadyClaimedError,
    AuthorizationExpiredError,
    Token,
    TokenExpiredError,
    TokenNotFoundError,
    UserEmailNotConfirmedError,
  }
  @moduletag :skip

  defp strip(user), do: Map.drop(user, [:actor, :email_confirm_tokens, :auth, :user])

  describe "MoodleNet.OAuth.fetch_auth/1" do
    test "works" do
      user = fake_user!(%{}, confirm_email: true)
      token = Repo.preload(fake_token!(user), :auth)
      assert {:ok, auth} = OAuth.fetch_auth(token.auth_id)
      assert strip(auth) == strip(token.auth)
    end
  end


  describe "MoodleNet.OAuth.fetch_auth_by/1" do
    test "works" do
      user = fake_user!(%{}, confirm_email: true)
      token = Repo.preload(fake_token!(user), :auth)
      assert {:ok, auth} = OAuth.fetch_auth_by(user_id: user.id)
      assert strip(auth) == strip(token.auth)
    end
  end

  describe "MoodleNet.OAuth.fetch_token_and_user/1" do

    test "works" do
      user = fake_user!(%{}, confirm_email: true)
      token = fake_token!(user)
      assert token.user_id == user.id
      assert {:ok, {token2, user2}} = OAuth.fetch_token_and_user(token.id)
      assert strip(token) == strip(token2)
      assert strip(user) == strip(user2)
    end

    test "fails with an invalid token" do
      user = fake_user!(%{}, confirm_email: true)
      token = fake_token!(user)
      assert token.user_id == user.id
      assert {:error, error} = OAuth.fetch_token_and_user(token.id <> token.id)
      assert %TokenNotFoundError{} == error
    end

  end

  describe "MoodleNet.OAuth.create_auth/1" do

    test "works" do
      user = fake_user!(%{}, confirm_email: true)
      assert {:ok, auth} = OAuth.create_auth(user)
      assert auth.user_id == user.id
      assert nil == auth.claimed_at
      assert %DateTime{} = auth.expires_at
      assert :gt == DateTime.compare(auth.expires_at, DateTime.utc_now())
    end

    test "fails with an unconfirmed email" do
      user = fake_user!(%{}, confirm_email: false)
      assert {:error, %UserEmailNotConfirmedError{user: user}} ==
        OAuth.create_auth(user)
    end

  end

  describe "MoodleNet.OAuth.claim_token/{1,2}" do

    test "works" do
      user = fake_user!(%{}, confirm_email: true)
      assert {:ok, auth} = OAuth.create_auth(user)
      assert {:ok, %Token{}=token} = OAuth.claim_token(auth)
      assert token.user_id == user.id
      assert token.auth_id == auth.id
    end

    test "fails with an expired authority" do
      user = fake_user!(%{}, confirm_email: true)
      assert {:ok, auth} = OAuth.create_auth(user)
      then = DateTime.add(auth.inserted_at, 60 * 11, :second)
      assert {:error, %AuthorizationExpiredError{authorization: auth}} ==
        OAuth.claim_token(auth, then)
    end

    test "fails with an already-claimed authority" do
      user = fake_user!(%{}, confirm_email: true)
      assert {:ok, auth} = OAuth.create_auth(user)
      assert {:ok, %Token{}=token} = OAuth.claim_token(auth)
      token = Repo.preload(token, :auth)
      assert {:error, %AuthorizationAlreadyClaimedError{authorization: token.auth}} ==
        OAuth.claim_token(token.auth)
    end

  end

  describe "MoodleNet.OAuth.hard_delete/1" do

    test "works with a Token" do
      user = fake_user!(%{}, confirm_email: true)
      token = fake_token!(user)
      {:ok, token2} = OAuth.hard_delete(token)
      assert deleted(token) == token2
      assert {:error, %NotFoundError{}} = OAuth.fetch_token_and_user(token.id)
    end

    test "works with an Authorization" do
      user = fake_user!(%{}, confirm_email: true)
      assert {:ok, auth} = OAuth.create_auth(user)
      assert {:ok, auth2} = OAuth.hard_delete(auth)
      assert {:error, %NotFoundError{key: auth.id}} == OAuth.fetch_auth(auth.id)
    end

  end

  describe "MoodleNet.OAuth.ensure_valid/{1,2}" do

    test "ok for a valid user" do
      user = fake_user!(%{}, confirm_email: true)
      assert :ok == OAuth.ensure_valid(user)
    end

    test "errors for a user without a confirmed email" do
      user = fake_user!(%{}, confirm_email: false)
      assert {:error, %UserEmailNotConfirmedError{user: user}} ==
        OAuth.ensure_valid(user)
    end

    test "ok for a valid auth" do
      user = fake_user!(%{}, confirm_email: true)
      assert {:ok, auth} = OAuth.create_auth(user)
      assert :ok == OAuth.ensure_valid(auth)
    end

    test "errors for an expired auth" do
      user = fake_user!(%{}, confirm_email: true)
      assert {:ok, auth} = OAuth.create_auth(user)
      then = DateTime.add(auth.inserted_at, 60 * 11, :second)
      assert {:error, %AuthorizationExpiredError{authorization: auth}} ==
        OAuth.ensure_valid(auth, then)
    end

    test "errors for an already claimed auth" do
      user = fake_user!(%{}, confirm_email: true)
      assert {:ok, auth} = OAuth.create_auth(user)
      assert {:ok, %Token{}=token} = OAuth.claim_token(auth)
      token = Repo.preload(token, :auth)
      assert {:error, %AuthorizationAlreadyClaimedError{authorization: token.auth}} ==
        OAuth.ensure_valid(token.auth)
    end

    test "ok for a valid token" do
      user = fake_user!(%{}, confirm_email: true)
      token = fake_token!(user)
      assert :ok == OAuth.ensure_valid(token)
    end

    test "errors for an expired token" do
      user = fake_user!(%{}, confirm_email: true)
      token = Repo.preload(fake_token!(user), :auth)
      then = DateTime.add(token.inserted_at, 60 * 11, :second)
      assert {:error, %TokenExpiredError{token: token}} ==
        OAuth.ensure_valid(token, then)
    end

  end

end
