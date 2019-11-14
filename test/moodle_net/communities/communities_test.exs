# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.CommunitiesTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking
  alias MoodleNet.Test.Fake
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Communities
  alias MoodleNet.Communities.Community

  describe "Communities.create/3" do
    test "creates a community valid attributes" do
      assert user = fake_user!()
      attrs = Fake.community()
      assert {:ok, community} = Communities.create(user, attrs)
      assert community.name == attrs.name
      assert community.creator_id == user.id
      assert community.actor.preferred_username == attrs.preferred_username
      assert community.is_public == attrs.is_public
    end

    test "fails if given invalid attributes" do
      user = fake_user!()
      assert {:error, changeset} = Communities.create(user, %{})
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

    test "works" do
      assert user = fake_user!()
      assert community = fake_community!(user, %{is_public: true})
      assert {:ok, updated_community} = Communities.update(community, %{is_public: false})
      assert updated_community.id == community.id
      refute updated_community.is_public
    end
  end

  describe "Communities.soft_delete/2" do
    test "works" do
      assert user = fake_user!()
      assert community = fake_community!(user)
      assert {:ok, deleted_community} = Communities.soft_delete(community)
      assert deleted_community.id == community.id
      assert deleted_community.deleted_at
    end
  end

  describe "Communities.fetch_actor" do
    test "works when an actor is already preloaded" do
      assert user = fake_user!()
      assert community = fake_community!(user)
      assert {:ok, %Actor{}} = Communities.fetch_actor(community)
    end

    test "works when an actor is not preloaded" do
      assert user = fake_user!()
      assert community = fake_community!(user)
      community = %Community{community | actor: %Ecto.Association.NotLoaded{}}
      assert {:ok, %Actor{}} = Communities.fetch_actor(community)
    end
  end

end
