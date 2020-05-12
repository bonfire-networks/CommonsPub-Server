# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.ActorsTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking
  alias MoodleNet.{Actors, Repo}
  alias MoodleNet.Common.NotFoundError
  alias MoodleNet.Test.Fake

  def assert_actor_equal(actor, attrs) do
    assert actor.canonical_url == attrs[:canonical_url]
    assert actor.preferred_username == attrs[:preferred_username]
    assert actor.signing_key == attrs[:signing_key]
  end

  describe "one" do
    test "returns an item by ID" do
      actor = fake_user!().actor
      assert {:ok, fetched} = Actors.one(id: actor.id)
      assert actor == fetched
    end

    test "returns an item by username" do
      actor = fake_user!().actor
      assert {:ok, fetched} = Actors.one(username: actor.preferred_username)
      assert actor == fetched
    end

    test "fails if item is missing" do
      assert {:error, %NotFoundError{}} = Actors.one(id: Fake.ulid())
    end
  end

  describe "is_username_available?" do
    test "returns true if username is unused" do
      assert Actors.is_username_available?(Fake.preferred_username())
    end

    test "returns false if username is used" do
      actor = fake_user!().actor
      refute Actors.is_username_available?(actor.preferred_username)
    end
  end

  describe "create" do
    test "creates a new actor with a revision" do
      Repo.transaction(fn ->
        attrs = Fake.actor()
        assert {:ok, actor} = Actors.create(attrs)
        assert_actor_equal(actor, attrs)
      end)
    end

    # test "drops invalid characters from preferred_username" do
    #  Repo.transaction(fn ->
    #    attrs = Fake.actor(%{preferred_username: "actor&name"})
    #    assert {:ok, actor} = Actors.create(attrs)
    #    assert actor.preferred_username == "actorname"
    #  end)
    # end

    test "doesn't drop allowed characters from preferred_username" do
      Repo.transaction(fn ->
        attrs = Fake.actor(%{preferred_username: "actor-name_underscore@instance.url"})
        assert {:ok, actor} = Actors.create(attrs)
        assert actor.preferred_username == "actor-name_underscore@instance.url"
      end)
    end

    test "returns an error if there are missing required attributes" do
      Repo.transaction(fn ->
        invalid_attrs = Map.delete(Fake.actor(), :preferred_username)
        assert {:error, changeset} = Actors.create(invalid_attrs)
        assert Keyword.get(changeset.errors, :preferred_username)
      end)
    end

    test "returns an error if the username is duplicated" do
      Repo.transaction(fn ->
        actor = fake_actor!()

        assert {:error, changeset} =
                 %{preferred_username: actor.preferred_username}
                 |> Fake.actor()
                 |> Actors.create()

        assert Keyword.get(changeset.errors, :preferred_username)
      end)
    end
  end

  describe "update" do
    test "updates an existing actor with valid attributes" do
      Repo.transaction(fn ->
        user = fake_user!()
        original_attrs = Fake.actor()
        assert {:ok, actor} = Actors.create(original_attrs)

        updated_attrs =
          original_attrs
          |> Map.take(~w(preferred_username signing_key)a)
          |> Fake.actor()

        assert {:ok, actor} = Actors.update(user, actor, updated_attrs)
        assert_actor_equal(actor, updated_attrs)
      end)
    end
  end
end
