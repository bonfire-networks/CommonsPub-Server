# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.TransmogrifierTest do
  use MoodleNet.DataCase
  alias ActivityPubWeb.Transmogrifier
  alias ActivityPub.Object

  import ActivityPub.Factory
  import Tesla.Mock

  setup do
    mock(fn
      %{method: :get, url: "https://pleroma.example/objects/410"} ->
        %Tesla.Env{status: 410}

      env ->
        apply(HttpRequestMock, :request, [env])
    end)

    :ok
  end

  describe "handle incoming" do
    test "it works for incoming deletes when object was deleted on origin instance" do
      note = insert(:note, %{data: %{"id" => "https://pleroma.example/objects/410"}})
      activity = insert(:note_activity, %{note: note})

      data =
        File.read!("test/fixtures/mastodon-delete.json")
        |> Poison.decode!()

      object =
        data["object"]
        |> Map.put("id", activity.data["object"])

      data =
        data
        |> Map.put("object", object)
        |> Map.put("actor", activity.data["actor"])

      {:ok, %Object{local: false}} = Transmogrifier.handle_incoming(data)

      object = Object.get_by_ap_id(note.data["id"])
      assert object.data["type"] == "Tombstone"
    end

    test "it errors when note still exists" do
      note_data =
        File.read!("test/fixtures/pleroma_note.json")
        |> Jason.decode!()

      note = insert(:note, data: note_data)
      activity = insert(:note_activity, %{note: note})

      data =
        File.read!("test/fixtures/mastodon-delete.json")
        |> Poison.decode!()

      object =
        data["object"]
        |> Map.put("id", activity.data["object"])

      data =
        data
        |> Map.put("object", object)
        |> Map.put("actor", activity.data["actor"])

      :error = Transmogrifier.handle_incoming(data)
    end
  end
end
