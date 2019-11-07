# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.PublisherTest do
  alias ActivityPub.Actor
  alias ActivityPubWeb.Publisher
  import ActivityPub.Factory
  use MoodleNet.DataCase

  test "it publishes an activity" do
    note_actor = actor()
    recipient_actor = actor()

    note =
      insert(:note, %{
        actor: note_actor,
        data: %{
          "to" => [recipient_actor.ap_id, "https://www.w3.org/ns/activitystreams#Public"],
          "cc" => note_actor.data["followers"]
        }
      })

    activity = insert(:note_activity, %{note: note})
    {:ok, actor} = Actor.get_by_ap_id(activity.data["actor"])

    assert :ok == Publisher.publish(actor, activity)
  end
end
