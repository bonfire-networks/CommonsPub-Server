# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.CommunitiesTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking
  alias MoodleNet.Test.Fake
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Common.NotFoundError
  alias MoodleNet.Communities
  alias MoodleNet.Communities.Community

  describe "Communities.list/1" do
    test "returns a list of non-deleted communities" do
      all = for _ <- 1..5, do: fake_user!() |> fake_community!()
      deleted = Enum.reduce(all, [], fn comm, acc ->
        if Fake.bool() do
          {:ok, comm} = Communities.soft_delete(comm)
          [comm | acc]
        else
          acc
        end
      end)
      fetched = Communities.list()

      assert Enum.count(all) - Enum.count(deleted) == Enum.count(fetched)
      for comm <- fetched do
        assert comm.actor
        assert comm.follower_count
        refute comm.deleted_at
      end
    end
  end

  describe "Communities.fetch/1" do
    test "returns a community by ID when available" do
      community = fake_user!() |> fake_community!()
      assert {:ok, community = %Community{}} = Communities.fetch(community.id)
      assert community.actor
      assert community.creator
    end

    test "fails if the community has been removed" do
      community = fake_user!() |> fake_community!()
      assert {:ok, community} = Communities.soft_delete(community)
      assert {:error, %NotFoundError{}} = Communities.fetch(community.id)
    end

    # Everything is public currently
    @tag :skip
    test "fails if the community is private" do
      community = fake_user!() |> fake_community!(%{is_public: false})
      assert {:error, %NotFoundError{}} = Communities.fetch(community.id)
    end

    test "fails when given a missing ID" do
      assert {:error, %NotFoundError{}} = Communities.fetch(Fake.ulid())
    end
  end

  describe "Communities.fetch_private/1" do
    test "returns a community regardless of its privacy" do
      community = fake_user!() |> fake_community!(%{is_public: false})
      assert {:ok, community} = Communities.soft_delete(community)
      assert {:ok, community = %Community{}} = Communities.fetch_private(community.id)
      assert community.actor
      assert community.creator
    end

    test "fails when given a missing ID" do
      assert {:error, %NotFoundError{}} = Communities.fetch_private(Fake.ulid())
    end
  end

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
      refute Enum.empty?(changeset.errors)
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
end
