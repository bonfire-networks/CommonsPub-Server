# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.ActorTest do
  use MoodleNet.DataCase

  alias MoodleNet.Test.Faking

  test "get_by_username/1" do
    actor = Faking.fake_actor!()

    username = actor.preferred_username

    {:ok, fetched_actor} = ActivityPub.Actor.get_by_username(username)

    assert fetched_actor.data["preferredUsername"] == username
  end
end
