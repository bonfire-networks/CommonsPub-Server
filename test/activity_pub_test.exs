# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubTest do
  use MoodleNet.DataCase
  alias ActivityPub.Utils

  doctest ActivityPub

  describe "create" do
    test "works" do
      actor = MoodleNet.Factory.ap_actor()
      context = "blabla"
      object = %{"content" => "content"}
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
end
