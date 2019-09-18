# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.ActorsTest do
  use MoodleNet.DataCase, async: true

  alias MoodleNet.Actors
  alias MoodleNet.Meta
  alias MoodleNet.Repo

  def gen_actor_params do
    %{
      "name" => Faker.Name.name(),
      "summary" => Faker.Lorem.paragraph(),
      "icon" => Faker.Avatar.image_url(),
      "preferred_username" => Faker.Internet.user_name(),
      "signing_key" => Faker.String.base64()
    }
  end

  def assert_actor_equal(actor, attrs) do
    assert actor.preferred_username == attrs["preferred_username"]
    assert actor.preferred_username == attrs["preferred_username"]
    assert actor.signing_key == attrs["signing_key"]
  end

  def assert_revision_equal(revision, attrs) do
    assert revision.name == attrs["name"]
    assert revision.summary == attrs["summary"]
    assert revision.icon == attrs["icon"]
  end

  setup do
    # FIXME: self reference
    pointer = Meta.TableService.lookup_id!("mn_actor")
    |> Meta.Pointer.changeset()
    |> Repo.insert!()

    {:ok, %{pointer: pointer}}
  end

  describe "create" do
    test "creates a new actor with a revision", %{pointer: pointer} do
      attrs = gen_actor_params()
      assert {:ok, actor} = Actors.create(pointer.id, attrs)
      assert_actor_equal actor, attrs

      assert actor = Repo.preload(actor, :actor_revisions)
      assert actor_revision = hd(actor.actor_revisions)
      assert_revision_equal actor_revision, attrs
    end

    test "returns an error if there are missing required attributes", %{pointer: pointer} do
      invalid_attrs = Map.delete(gen_actor_params(), "preferred_username")
      assert {:error, changeset} = Actors.create(pointer.id, invalid_attrs)
      assert Keyword.get(changeset.errors, :preferred_username)
    end
  end

  describe "update" do
    test "updates an existing actor with valid attributes and adds revision", %{pointer: pointer} do
      original_attrs = gen_actor_params()
      assert {:ok, actor} = Actors.create(pointer.id, original_attrs)

      updated_attrs = gen_actor_params()
      assert {:ok, actor} = Actors.update(actor, updated_attrs)
      assert_actor_equal actor, updated_attrs

      assert actor = Repo.preload(actor, :actor_revisions)
      assert Enum.count(actor.actor_revisions) == 2

      assert original_revision = List.first(actor.actor_revisions)
      assert_revision_equal original_revision, original_attrs

      assert latest_revision = List.last(actor.actor_revisions)
      assert_revision_equal latest_revision, updated_attrs
    end
  end
end
