# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubTest do
  use MoodleNet.DataCase
  import MoodleNet.Factory

  doctest ActivityPub

  describe "create" do
    test "works" do
      actor = ap_actor()
      context = "blabla"
      object = %{"content" => "content", "type" => "Note"}
      to = ["https://testing.kawen.dance/users/karen"]

      params = %{
        actor: actor,
        context: context,
        object: object,
        to: to
      }

      {:ok, activity} = ActivityPub.create(params)

      assert actor.data["id"] == activity.data["actor"]
      assert activity.data["object"] == activity.object.data["id"]
    end
  end

  describe "following / unfollowing" do
    test "creates a follow activity" do
      follower = ap_actor()
      followed = ap_actor()

      {:ok, activity} = ActivityPub.follow(follower, followed)
      assert activity.data["type"] == "Follow"
      assert activity.data["actor"] == follower.data["id"]
      assert activity.data["object"] == followed.data["id"]
    end
  end

  test "creates an undo activity for the last follow" do
    follower = ap_actor()
    followed = ap_actor()

    {:ok, follow_activity} = ActivityPub.follow(follower, followed)
    {:ok, activity} = ActivityPub.unfollow(follower, followed)

    assert activity.data["type"] == "Undo"
    assert activity.data["actor"] == follower.data["id"]

    embedded_object = activity.data["object"]
    assert is_map(embedded_object)
    assert embedded_object["type"] == "Follow"
    assert embedded_object["object"] == followed.data["id"]
    assert embedded_object["id"] == follow_activity.data["id"]
  end
end
