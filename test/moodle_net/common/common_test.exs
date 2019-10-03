# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.CommonTest do
  use MoodleNet.DataCase, async: true
  import MoodleNet.Test.Faking
  # alias MoodleNet.Test.Fake
  alias MoodleNet.{Common, Localisation, Meta}

  defp english(), do: Localisation.language!("en")

  describe "like/3" do
    test "with a community" do
      assert actor = fake_actor!()
      assert language = english()
      assert community = fake_community!(actor, language)
      assert {:ok, like} = Common.like(actor, community, %{is_public: true})
      assert like.liker_id == actor.id
      assert like.liked_id == community.id
    end

    test "with an actor" do
      assert alice = fake_actor!()
      assert bob = fake_actor!()
      assert {:ok, like} = Common.like(alice, bob, %{is_public: true})
      assert like.liker_id == alice.id
      assert like.liked_id == bob.id
    end
  end

  describe "likes_by/1" do
  end

  describe "likes_of/1" do
  end
end
