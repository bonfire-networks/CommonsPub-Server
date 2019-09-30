# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.CommunitiesTest do
  use MoodleNet.DataCase, async: true

  import ActivityPub.Entity, only: [local_id: 1]
  alias MoodleNet.{Actors, Communities}
  alias MoodleNet.Test.{Fake, Faking}

  describe "create" do
    test "creates a community given valid attributes" do
      actor = Faking.fake_actor!()
      language = Faking.fake_language!()

      attrs = Fake.community()
      assert {:ok, community} = Communities.create(actor, language, attrs)
      assert community.creator_id == actor.id
      assert community.primary_language_id == language.id
      assert community.is_public == attrs[:is_public]
    end

    test "fails if given invalid attributes" do
      actor = Faking.fake_actor!()
      language = Fake.fake_language!()
      assert {:error, changeset} = Communities.create(actor, language, %{})
      assert Keyword.get(changeset.errors, :is_public)
    end
  end

  describe "update" do
    test "updates a community with the given attributes" do
      community = Faking.fake_community!(%{is_public: true})
      assert {:ok, updated_community} = Communities.update(community, %{is_public: false})
      assert updated_community != community
      refute updated_community.is_public
    end
  end

  describe "membership" do
    test "joining" do
      # Communities.join()
    end

    test "leaving" do
    end

    test "listing" do
    end

    test "listing as admin" do
    end
  end

  describe "community flags" do
    test "works" do
      actor = Faking.fake_actor!()
      comm = Faking.fake_community!(%{creator_id: actor.id})

      assert [] = Communities.all_flags(actor)

      {:ok, _activity} = Communities.flag(actor, comm, %{reason: "Terrible joke"})

      assert [flag] = Communities.all_flags(actor)
      assert flag.flagged_object_id == comm.id
      assert flag.flagging_object_id == actor.id
      assert flag.reason == "Terrible joke"
      assert flag.open == true
    end
  end
end
