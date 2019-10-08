# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.CollectionsTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking
  alias MoodleNet.Collections
  alias MoodleNet.Test.Fake

  setup do
    actor = fake_actor!()
    language = fake_language!()
    community = fake_community!(actor, language)
    collection = fake_collection!(actor, community, language)
    {:ok, %{actor: actor, language: language, community: community, collection: collection}}
  end

  describe "create" do
    test "creates a new collection", context do
      attrs = Fake.collection()

      assert {:ok, collection} =
               Collections.create(context.community, context.actor, context.language, attrs)

      assert collection.community_id == context.community.id
      assert collection.is_public == attrs[:is_public]
    end

    test "fails if given invalid attributes", context do
      assert {:error, changeset} =
               Collections.create(context.community, context.actor, context.language, %{})

      assert Keyword.get(changeset.errors, :is_public)
    end
  end

  describe "update" do
    test "updates a collection with the given attributes", %{collection: collection} do
      assert {:ok, updated_collection} = Collections.update(collection, %{is_public: false})
      refute updated_collection.is_public
    end
  end
end
