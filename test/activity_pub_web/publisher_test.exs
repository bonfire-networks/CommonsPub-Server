# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.PublisherTest do
  alias ActivityPub.Actor
  alias ActivityPubWeb.Publisher
  import ActivityPub.Factory
  import Tesla.Mock
  use MoodleNet.DataCase

  setup do
    mock fn
      %{method: :post} -> %Tesla.Env{status: 200}
    end

    :ok
  end

  test "it publishes an activity" do
    note_actor = MoodleNet.Test.Faking.fake_actor!()
    {:ok, note_actor} = Actor.get_by_username(note_actor.preferred_username)
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
    assert %{success: 1, failure: 0} = Oban.drain_queue(:federator_outgoing)
  end
end
