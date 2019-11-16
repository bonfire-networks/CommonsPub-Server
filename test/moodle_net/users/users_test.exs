# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.UsersTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking
  alias Ecto.Changeset
  alias MoodleNet.{Users, Access}
  alias MoodleNet.Users.{
    TokenAlreadyClaimedError,
    TokenExpiredError,
    User,
  }
  alias MoodleNet.Access.NoAccessError
  alias MoodleNet.Test.Fake

  describe "register/1" do

    test "creates a user account with valid attrs when public registration is enabled" do
      Repo.transaction(fn ->
        attrs = Fake.actor(Fake.user())
        assert {:ok, user} = Users.register(attrs, public_registration: true)
	
	assert user.actor.preferred_username == attrs.preferred_username
	assert user.actor.alias_id == user.id
        assert user.email == attrs.email
        assert user.wants_email_digest == attrs.wants_email_digest
        assert user.wants_notifications == attrs.wants_notifications
	assert [token] = user.email_confirm_tokens
	assert nil == token.confirmed_at
      end)
    end

    test "creates a user account with valid attrs when email whitelisted" do
      Repo.transaction(fn ->
        attrs = Fake.actor(Fake.user())
	assert {:ok, _} = Access.create_register_email(attrs.email)
        assert {:ok, user} = Users.register(attrs, public_registration: false)
	assert user.actor.preferred_username == attrs.preferred_username
	assert user.actor.alias_id == user.id
        assert user.email == attrs.email
        assert user.wants_email_digest == attrs.wants_email_digest
        assert user.wants_notifications == attrs.wants_notifications
	assert [token] = user.email_confirm_tokens
	assert nil == token.confirmed_at
      end)
    end

    test "creates a user account with valid attrs when domain whitelisted" do
      Repo.transaction(fn ->
        attrs = Fake.actor(Fake.user())
	[_,domain] = String.split(attrs.email, "@", parts: 2)
	assert {:ok, _} = Access.create_register_email_domain(domain)
        assert {:ok, user} = Users.register(attrs, public_registration: false)
	assert user.actor.preferred_username == attrs.preferred_username
	assert user.actor.alias_id == user.id
        assert user.email == attrs.email
        assert user.wants_email_digest == attrs.wants_email_digest
        assert user.wants_notifications == attrs.wants_notifications
	assert [token] = user.email_confirm_tokens
	assert nil == token.confirmed_at
      end)
    end

    test "fails if the username is already taken" do
      Repo.transaction fn ->
	assert user = fake_user!()
        attrs =
          %{preferred_username: user.actor.preferred_username}
          |> Fake.user()
          |> Fake.actor()
        assert {:error, %Changeset{} = error} =
	  Users.register(attrs, public_registration: true)
      end
    end

    test "fails if given invalid attributes" do
      Repo.transaction fn ->
        invalid_attrs = Map.delete(Fake.user(), :email)
        assert {:error, changeset} = Users.register(invalid_attrs, public_registration: true)
        assert Keyword.get(changeset.errors, :email)
      end
    end

    test "fails if the user's email is not whitelisted - email whitelist" do
      Repo.transaction(fn ->
        attrs = Fake.actor(Fake.user())
        assert {:error, %NoAccessError{}} ==
	        Users.WhitelistsTestregister(attrs, public_registration: false)
      end)
    end
  end

  describe "claim_confirm_email_token/2" do

    test "confirms a user's email" do
      assert user = fake_user!()
      assert [token] = user.email_confirm_tokens
      assert {:ok, %User{} = user} = Users.claim_email_confirm_token(token.id)
      assert user.confirmed_at
    end

    test "will not confirm if the token is expired" do
      assert user = fake_user!()
      assert [token] = user.email_confirm_tokens
      assert then = DateTime.add(DateTime.utc_now(), 60 * 60 * 49, :second)
      assert {:error, %TokenExpiredError{}=error} =
	Users.claim_email_confirm_token(token.id, then)
      assert error.token.id == token.id
      assert error.token.expires_at == token.expires_at
      assert error.token.inserted_at == token.inserted_at
      assert error.token.user_id == user.id
    end

    test "will not claim twice" do
      assert user = fake_user!()
      assert [token] = user.email_confirm_tokens
      assert {:ok, %User{} = user} = Users.claim_email_confirm_token(token.id)
      assert {:error, %TokenAlreadyClaimedError{}=error} =
	Users.claim_email_confirm_token(token.id)
      assert error.token.id == token.id
      assert error.token.expires_at == token.expires_at
      assert error.token.inserted_at == token.inserted_at
      assert error.token.user_id == user.id
    end

  end
  describe "confirm_email/1" do
    test "sets the confirmed date" do
      Repo.transaction(fn ->
	assert user = fake_user!()
	assert user.confirmed_at == nil
        assert {:ok, user2} = Users.confirm_email(user)
	assert %DateTime{} = user2.confirmed_at
       end)
    end
  end

  describe "unconfirm_email/1" do
    test "unsets the confirmed date" do
      Repo.transaction(fn ->
	assert user = fake_user!()
	assert user.confirmed_at == nil
        assert {:ok, user2} = Users.confirm_email(user)
	assert %DateTime{} = user2.confirmed_at
	assert user.id == user2.id
	assert {:ok, user3} = Users.unconfirm_email(user)
	assert user3.confirmed_at == nil
	assert timeless(user) == timeless(user3)
      end)
    end
  end

  describe "request_password_reset" do
    test "creates a reset password token for a valid user" do
      user = fake_user!()
      assert {:ok, token} = Users.request_password_reset(user)
      assert token.user_id == user.id
      assert token.expires_at
      refute token.reset_at
    end
  end

  describe "claim_password_reset" do
    test "claims a reset token and changes the password" do
      user = fake_user!()
      assert {:ok, token} = Users.request_password_reset(user)
      refute token.reset_at
      assert {:ok, token} = Users.claim_password_reset(token.id, "password")
      assert token.reset_at

      assert {:ok, updated_user} = Users.fetch(user.id)
      assert user.password_hash != updated_user.password_hash
    end
  end

  describe "soft_delete/1" do
    test "updates the deletion timestamp" do
      user = fake_user!()
      refute user.deleted_at
      assert {:ok, user} = Users.soft_delete(user)
      assert user.deleted_at
      assert user.actor.deleted_at
    end
  end

  # describe "user flags" do
  #   test "works" do
  #     actor = Factory.actor()
  #     actor_id = local_id(actor)
  #     user = Factory.actor()
  #     user_id = local_id(user)

  #     assert [] = Users.all_flags(actor)

  #     {:ok, _activity} = Users.flag(actor, user, %{reason: "Terrible joke"})

  #     assert [flag] = Users.all_flags(actor)
  #     assert flag.flagged_object_id == user_id
  #     assert flag.flagging_object_id == actor_id
  #     assert flag.reason == "Terrible joke"
  #     assert flag.open == true
  #   end
  # end
end
