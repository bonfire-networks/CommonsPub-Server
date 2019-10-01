# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.ActorsTest do
  use MoodleNet.DataCase, async: true

  alias MoodleNet.{Actors, Repo}
  alias MoodleNet.Test.Fake

  def assert_actor_equal(actor, attrs) do
    assert actor.preferred_username == attrs[:preferred_username]
    assert actor.signing_key == attrs[:signing_key]
  end

  def assert_revision_equal(revision, attrs) do
    assert revision.name == attrs[:name]
    assert revision.summary == attrs[:summary]
    assert revision.icon == attrs[:icon]
  end

  describe "create" do
    test "creates a new actor with a revision" do
      Repo.transaction(fn ->
        attrs = Fake.actor()
        assert {:ok, actor} = Actors.create(attrs)
        assert_actor_equal(actor, attrs)

        assert actor = Repo.preload(actor, [:revisions, :current])
        assert [actor_revision] = actor.revisions
        assert_revision_equal(actor_revision, attrs)
	      assert_revision_equal(actor.current, attrs)
      end)
    end

    test "returns an error if there are missing required attributes" do
      Repo.transaction(fn ->
        invalid_attrs = Map.delete(Fake.actor(), :preferred_username)
        assert {:error, changeset} = Actors.create(invalid_attrs)
        assert Keyword.get(changeset.errors, :preferred_username)
      end)
    end
  end

  describe "create_with_alias" do
    test "creates a new actor with an alias set" do
      Repo.transaction(fn ->
        assert {:ok, actor_alias} = Actors.create(Fake.actor())
        assert {:ok, _} = Actors.create_with_alias(actor_alias.id, Fake.actor())
      end)
    end
  end

  describe "update" do
    test "updates an existing actor with valid attributes and adds revision" do
      Repo.transaction(fn ->
        original_attrs = Fake.actor()
        assert {:ok, actor} = Actors.create(original_attrs)

        updated_attrs =
          original_attrs
          |> Map.take(~w(preferred_username signing_key)a)
          |> Fake.actor()

        assert {:ok, actor} = Actors.update(actor, updated_attrs)
        assert_actor_equal(actor, updated_attrs)

        assert actor = Repo.preload(actor, :revisions)
        assert Enum.count(actor.revisions) == 2

        assert [latest_revision, oldest_revision] = actor.revisions
        assert_revision_equal(latest_revision, updated_attrs)
        assert_revision_equal(oldest_revision, original_attrs)
      end)
    end
  end
end
