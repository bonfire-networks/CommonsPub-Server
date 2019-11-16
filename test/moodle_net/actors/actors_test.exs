# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.ActorsTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking
  alias MoodleNet.{Actors, Repo}
  alias MoodleNet.Test.Fake

  def assert_actor_equal(actor, attrs) do
    assert actor.canonical_url == attrs[:canonical_url]
    assert actor.preferred_username == attrs[:preferred_username]
    assert actor.signing_key == attrs[:signing_key]
  end

  describe "create" do
    test "creates a new actor with a revision" do
      Repo.transaction(fn ->
        attrs = Fake.actor()
        assert {:ok, actor} = Actors.create(attrs)
        assert_actor_equal(actor, attrs)
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
        original_attrs = Fake.actor()
        assert {:ok, actor} = Actors.create(original_attrs)

        updated_attrs =
          original_attrs
          |> Map.take(~w(preferred_username signing_key)a)
          |> Fake.actor()

        assert {:ok, actor} = Actors.update(actor, updated_attrs)
        assert_actor_equal(actor, updated_attrs)
      end)
    end
  end
end
