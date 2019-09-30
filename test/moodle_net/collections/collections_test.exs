# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.CollectionsTest do
  use MoodleNet.DataCase, async: true

  import ActivityPub.Entity, only: [local_id: 1]
  alias MoodleNet.Collections
  alias MoodleNet.Test.{Fake, Faking}

  describe "create" do
    test "creates a new collection" do
      creator = Faking.fake_actor!()
      community = Faking.fake_community!(%{creator_id: creator.id})
      language = Faking.fake_language!()
      attrs = Fake.collection()
      assert {:ok, collection} = Collections.create(community, creator, language, attrs)
      assert collection.community_id == community.id
    end

    test "fails if given invalid attributes" do
      creator = Faking.fake_actor!()
      community = Faking.fake_community!(%{creator_id: creator.id})
      language = Faking.fake_language!()
      assert {:error, changeset} = Collections.create(community, creator, language, %{})
      assert Keyword.get(changeset.errors, :is_public)
    end
  end

  describe "update" do
    test "updates a collection with the given attributes" do
      collection = Faking.fake_collection!(%{is_public: true})
      assert {:ok, updated_collection} = Collections.update(collection, %{is_public: false})
      refute updated_collection.is_public
    end
  end

  describe "collection flags" do
    test "works" do
      actor = Factory.actor()
      actor_id = local_id(actor)
      comm = Factory.community(actor)
      coll = Factory.collection(actor, comm)
      coll_id = local_id(coll)

      assert [] = Collections.all_flags(actor)

      {:ok, _activity} = Collections.flag(actor, coll, %{reason: "Terrible joke"})

      assert [flag] = Collections.all_flags(actor)
      assert flag.flagged_object_id == coll_id
      assert flag.flagging_object_id == actor_id
      assert flag.reason == "Terrible joke"
      assert flag.open == true
    end
  end
end
