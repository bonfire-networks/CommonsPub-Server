# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.ActorTest do
  use MoodleNet.DataCase
  import Tesla.Mock

  alias ActivityPub.Actor
  alias MoodleNet.Test.Faking

  setup do
    mock(fn env -> apply(HttpRequestMock, :request, [env]) end)
    :ok
  end

  test "get_by_username/1" do
    actor = Faking.fake_actor!()

    username = actor.preferred_username

    {:ok, fetched_actor} = ActivityPub.Actor.get_by_username(username)

    assert fetched_actor.data["preferredUsername"] == username
  end

  test "fetch_by_username/1" do
    {:ok, actor} = Actor.fetch_by_username("karen@kawen.space")

    assert actor.data["preferredUsername"] == "karen"
  end
end
