# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.UsersTest do
  use MoodleNet.DataCase, async: true

  alias MoodleNet.Test.Fake
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Users

  describe "register" do
    test "creates a user account" do
      Repo.transaction(fn ->
        attrs = Fake.user()
        assert {:ok, user} = Users.register(attrs)
        assert user.email == attrs.email
        assert user.wants_email_digest == attrs.wants_email_digest
        assert user.wants_notifications == attrs.wants_notifications
      end)
    end

    test "fails if given invalid attributes" do
      Repo.transaction(fn ->
        invalid_attrs = Map.delete(Fake.user(), :email)
        assert {:error, changeset} = Users.register(invalid_attrs)
        assert Keyword.get(changeset.errors, :email)
      end)
    end
  end

  describe "verify" do
    test "sets the confirmed date and creates an actor" do
      Repo.transaction(fn ->
        attrs = Fake.user()
        assert {:ok, user} = Users.register(attrs)
        assert {:ok, user} = Users.verify(user, Fake.actor())

        assert Repo.get_by!(Actor, alias_id: user.id)
      end)
    end

    test "fails if there are missing actor attributes" do
      Repo.transaction(fn ->
        assert {:ok, user} = Users.register(Fake.user())
        assert {:error, _} = Users.verify(user, %{})
      end)
    end
  end
end
