# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.ActivitiesTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking

  alias MoodleNet.Activities
  alias MoodleNet.Activities.Activity
  alias MoodleNet.Communities.Community
  alias MoodleNet.Common.NotFoundError
  alias MoodleNet.Test.Fake

  setup do
    user = fake_user!()
    comm = fake_community!(user)
    {:ok, %{user: user, context: comm}}
  end

  describe "list_by_context" do
    test "returns a list of activities for a context", %{context: context} do
      # When we create a community, it inserts an activity to link to outboxes
      assert [creation] = Activities.list_by_context(context)
      known =
        for _ <- 1..5 do
          user = fake_user!()
          fake_activity!(user, context)
        end
      found = Activities.list_by_context(context)
      assert Enum.count(found) == 1 + Enum.count(known)
    end
  end

  describe "list_by_user" do
    test "returns a list of activities for a user", %{user: user} do
      # When we create a community, it inserts an activity to link to outboxes
      assert [creation] = Activities.list_by_user(user)
      found =
        for _ <- 1..5 do
          context = fake_community!(fake_user!())
          fake_activity!(user, context)
        end

      assert Enum.count(Activities.list_by_user(user)) == 1 + Enum.count(found)
    end

    test "excludes unpublished activities", %{user: user} do
      # When we create a community, it inserts an activity to link to outboxes
      assert [creation] = Activities.list_by_user(user)
      found =
        for _ <- 1..5 do
          context = fake_community!(fake_user!())
          fake_activity!(user, context)
        end

      unpublished =
        Enum.reduce(found, [], fn activity, acc ->
          if Fake.bool() do
            {:ok, activity} = Activities.update(activity, %{is_public: false})
            [activity | acc]
          else
            acc
          end
        end)

      fetched = Activities.list_by_user(user)

      assert 1 + Enum.count(found) - Enum.count(unpublished) == Enum.count(fetched)
    end

    test "excludes deleted activities", %{user: user} do
      # When we create a community, it inserts an activity to link to outboxes
      assert [creation] = Activities.list_by_user(user)
      found =
        for _ <- 1..5 do
          context = fake_community!(fake_user!())
          fake_activity!(user, context)
        end

      deleted =
        Enum.reduce(found, [], fn activity, acc ->
          if Fake.bool() do
            {:ok, activity} = Activities.soft_delete(activity)
            [activity | acc]
          else
            acc
          end
        end)

      fetched = Activities.list_by_user(user)

      assert 1 + Enum.count(found) - Enum.count(deleted) == Enum.count(fetched)
    end
  end

  describe "fetch" do
    test "returns an activity by ID", %{user: user, context: context} do
      activity = fake_activity!(user, context)
      assert {:ok, fetched} = Activities.fetch(activity.id)
      assert fetched.id == activity.id
    end

    test "ignores activities that are unpublished", %{user: user, context: context} do
      activity = fake_activity!(user, context)
      assert {:ok, activity} = Activities.update(activity, %{is_public: false})
      assert {:error, %NotFoundError{}} = Activities.fetch(activity.id)
    end

    test "ignores activities that are deleted", %{user: user, context: context} do
      activity = fake_activity!(user, context)
      assert {:ok, activity} = Activities.soft_delete(activity)
      assert {:error, %NotFoundError{}} = Activities.fetch(activity.id)
    end
  end

  describe "fetch_private" do
    test "returns an activity by ID regardless of published or deleted status", %{
      user: user,
      context: context
    } do
      activity = fake_activity!(user, context)
      assert {:ok, activity} = Activities.fetch_private(activity.id)
      assert {:ok, activity} = Activities.update(activity, %{is_public: false})
      assert {:ok, activity} = Activities.fetch_private(activity.id)
      assert {:ok, activity} = Activities.soft_delete(activity)
      assert {:ok, _} = Activities.fetch_private(activity.id)
    end
  end

  describe "fetch_user" do
    test "returns the related user of an activity", %{user: user, context: context} do
      activity = fake_activity!(user, context) |> Map.drop([:user])
      # re-fetch to remove preloads
      assert {:ok, activity} = Activities.fetch(activity.id)
      assert {:ok, fetched} = Activities.fetch_user(activity)
      assert fetched.id == user.id
    end
  end

  describe "fetch_context" do
    test "returns the related context of an activity", %{user: user, context: context} do
      activity = fake_activity!(user, context)
      # re-fetch to remove preloads
      assert {:ok, activity} = Activities.fetch(activity.id)
      assert {:ok, %Community{} = fetched} = Activities.fetch_context(activity)
      assert fetched.id == context.id
    end
  end

  describe "create" do
    test "creates a new activity", %{user: user, context: context} do
      attrs = Fake.activity()
      assert {:ok, %Activity{} = activity} = Activities.create(user, context, attrs)
      assert activity.verb == attrs.verb
      assert activity.canonical_url == attrs.canonical_url
      assert activity.creator.id == user.id
      assert activity.context.id == context.id
    end

    test "fails if missing attributes", %{user: user, context: context} do
      assert {:error, changeset} = Activities.create(user, context, %{})
      assert Keyword.get(changeset.errors, :verb)
    end
  end

  describe "update" do
    test "updates an activity with new attributes", %{user: user, context: context} do
      activity = fake_activity!(user, context)
      assert attrs = Fake.activity()
      assert {:ok, updated_activity} = Activities.update(activity, attrs)
      assert updated_activity != activity
      assert updated_activity.verb == attrs.verb
      assert updated_activity.canonical_url == attrs.canonical_url
    end
  end

  describe "soft_delete" do
    test "changes the deletion date of an activity", %{user: user, context: context} do
      activity = fake_activity!(user, context)
      refute activity.deleted_at
      assert {:ok, activity} = Activities.soft_delete(activity)
      assert activity.deleted_at
    end
  end
end
