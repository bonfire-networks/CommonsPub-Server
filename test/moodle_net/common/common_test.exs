# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.CommonTest do
  use MoodleNet.DataCase, async: true
  import MoodleNet.Test.Faking
  alias MoodleNet.{Common, Meta}

  setup do
    {:ok, %{actor: fake_actor!(), language: fake_language!()}}
  end

  describe "like/3" do
    test "an actor can like any meta object", %{actor: liker, language: language} do
      actor = fake_actor!()
      community = fake_community!(liker, language)
      collection = fake_collection!(liker, community, language)
      resource = fake_resource!(liker, collection, language)
      thread = fake_thread!(Meta.find!(resource.id))
      comment = fake_comment!(thread)
      likeable = [actor, community, collection, resource, comment]

      for liked <- likeable do
        assert {:ok, like} = Common.like(liker, liked, %{is_public: true})
        assert like.liker_id == liker.id
        assert like.liked_id == liked.id
        assert like.published_at
      end
    end
  end

  describe "likes_by/1" do
    test "returns a list of likes for an actor", %{actor: actor, language: language} do
      thread = fake_thread!(Meta.find!(actor.id))
      things = [fake_actor!(), fake_community!(actor, language), fake_comment!(thread)]

      for thing <- things do
        assert {:ok, like} = Common.like(actor, thing, %{is_public: true})
      end

      likes = Common.likes_by(actor)
      assert Enum.count(likes) == 3
      for like <- likes do
        assert like.liker_id == actor.id
        assert Enum.any?(things, fn thing -> thing.id == like.liked_id end)
      end
    end
  end

  describe "likes_of/1" do
    test "returns a list of likes by actors for any meta object", context do
      thing = fake_community!(context.actor, context.language)
      actors = for _ <- 1..3, do: fake_actor!()
      for actor <- actors do
        assert {:ok, like} = Common.like(actor, thing, %{is_public: true})
      end

      likes = Common.likes_of(thing)
      assert Enum.count(likes) == 3
      for like <- likes do
        assert like.liked_id == thing.id
        assert Enum.any?(actors, fn actor -> actor.id == like.liker_id end)
      end
    end
  end
end
