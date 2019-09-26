# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.ResourcesTest do
  use MoodleNet.DataCase, async: true

  alias MoodleNet.{Resources, Repo}
  alias MoodleNet.Test.{Fake, Faking}

  describe "create" do
    test "creates a new resource given valid attributes" do
      Repo.transaction(fn ->
        creator = Faking.fake_actor!()
        collection = Faking.fake_collection!()

        assert {:ok, resource} =
          %{
            creator_id: creator.id,
            collection_id: collection.id,
            primary_language_id: collection.primary_language_id
          }
          |> Fake.resource()
          |> Resources.create()

        assert resource.collection_id == collection.id
        assert resource.creator_id == creator.id
      end)
    end

    test "fails given invalid attributes" do
      Repo.transaction(fn ->
        assert {:error, changeset} = Resources.create(%{})
        assert Keyword.get(changeset.errors, :creator_id)
        assert Keyword.get(changeset.errors, :collection_id)
        assert Keyword.get(changeset.errors, :primary_language_id)
        assert Keyword.get(changeset.errors, :is_public)
      end)
    end
  end

  describe "update" do
    test "updates a resource given valid attributes" do
      resource = Faking.fake_resource!(%{is_public: true})
      assert {:ok, updated_resource} = Resources.update(resource, %{is_public: false})
      assert updated_resource != resource
      refute updated_resource.is_public
    end
  end

  describe "resource flags" do
    @tag :skip
    test "works" do
      actor = Faking.fake_actor!()
      comm = Faking.fake_community!()
      coll = Faking.fake_collection!(%{creator_id: actor.id, community_id: comm.id})
      res = Faking.fake_resource!(%{creator_id: actor.id, collection_id: coll.id})

      assert [] = Resources.all_flags(actor)

      {:ok, _activity} = Resources.flag(actor, res, %{reason: "Terrible joke"})

      assert [flag] = Resources.all_flags(actor)
      assert flag.flagged_object_id == res.id
      assert flag.flagging_object_id == actor.id
      assert flag.reason == "Terrible joke"
      assert flag.open == true
    end
  end

end
