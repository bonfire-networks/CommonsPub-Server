# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.CollectionsTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking
  alias MoodleNet.Collections
  alias MoodleNet.Test.Fake

  setup do
    user = fake_user!()
    community = fake_community!(user)
    collection = fake_collection!(user, community)
    {:ok, %{user: user, community: community, collection: collection}}
  end

  describe "create" do
    test "creates a new collection", context do
      attrs = Fake.collection()

      assert {:ok, collection} =
               Collections.create(context.community, context.user.actor, attrs)

      assert collection.community_id == context.community.id
      # assert collection.is_public == attrs[:is_public]
    end

    test "fails if given invalid attributes", context do
      assert {:error, changeset} =
               Collections.create(context.community, context.user.actor, %{})

      # assert Keyword.get(changeset.errors, :is_public)
    end
  end

  describe "update" do
    @tag :skip
    @for_moot true
    test "updates a collection with the given attributes", %{collection: collection} do
      assert {:ok, updated_collection} = Collections.update(collection, %{is_public: false})
      refute updated_collection.is_public
    end
  end

  describe "soft_delete" do

    @tag :skip
    @for_moot true
    test "works" do
    end

    @tag :skip
    @for_moot true
    test "doesn't work if it can't find a" do
    end
  end

end
