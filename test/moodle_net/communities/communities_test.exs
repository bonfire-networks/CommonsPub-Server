# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.CommunitiesTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking
  alias MoodleNet.Test.Fake
  alias MoodleNet.{Communities, Localisation}

  describe "Communities.create/3" do
    test "creates a community valid attributes" do
      assert user = fake_user!()
      attrs = Fake.community()
      assert {:ok, community} = Communities.create(user, user.actor, attrs)
      assert community.creator_id == user.actor.id
      assert community.actor.primary_language_id == "en"
      assert community.is_public == attrs[:is_public]
    end

    test "fails if given invalid attributes" do
      user = fake_user!()
      assert {:error, changeset} = Communities.create(user, user.actor, %{})
    end
  end

  describe "Communities.update/2" do

    @tag :skip
    @for_moot true
    test "works for the creator of the community" do
      # assert user = fake_user!()
      # assert community = fake_community!(user)
      # assert {:ok, updated_community} = Communities.update(community, %{is_public: false})
      # assert updated_community.id == community.id
      # refute updated_community.is_public
    end

    @tag :skip
    @for_moot true
    test "works for an instance admin" do
      # assert user = fake_user!()
      # assert community = fake_community!(user)
      # assert {:ok, updated_community} = Communities.update(community, %{is_public: false})
      # assert updated_community.id == community.id
      # refute updated_community.is_public
    end

  end

  describe "Communities.soft_delete/2" do
    @tag :skip
    @for_moot true
    test "works" do
    end

    @tag :skip
    @for_moot true
    test "does not work if not found" do
    end
  end

  describe "Communities.fetch_actor" do

    @tag :skip
    @for_moot true
    test "works when an actor is already preloaded" do
    end

    @tag :skip
    @for_moot true
    test "works when an actor is not preloaded" do
    end

  end

end
