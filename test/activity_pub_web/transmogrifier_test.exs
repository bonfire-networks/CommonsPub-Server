# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.TransmogrifierTest do
  use MoodleNet.DataCase
  alias ActivityPubWeb.Transmogrifier
  alias ActivityPub.Actor
  alias ActivityPub.Object
  alias MoodleNet.Test.Faking

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
        |> Poison.decode!()

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

    test "it returns an error for incoming unlikes wihout a like activity" do
      data =
        File.read!("test/fixtures/mastodon-undo-like.json")
        |> Poison.decode!()

      assert Transmogrifier.handle_incoming(data) == :error
    end

    test "it works for incoming likes" do
      actor = Faking.fake_actor!()
      {:ok, note_actor} = Actor.get_by_username(actor.preferred_username)
      note_activity = insert(:note_activity, %{actor: note_actor})
      delete_actor = insert(:actor)

      data =
        File.read!("test/fixtures/mastodon-like.json")
        |> Poison.decode!()
        |> Map.put("object", note_activity.data["object"])
        |> Map.put("actor", delete_actor.data["id"])

      {:ok, %Object{data: data, local: false}} = Transmogrifier.handle_incoming(data)

      assert data["actor"] == delete_actor.data["id"]
      assert data["type"] == "Like"
      assert data["id"] == "http://mastodon.example.org/users/admin#likes/2"
      assert data["object"] == note_activity.data["object"]
    end

    test "it works for incoming unlikes with an existing like activity" do
      actor = Faking.fake_actor!()
      {:ok, note_actor} = Actor.get_by_username(actor.preferred_username)
      note_activity = insert(:note_activity, %{actor: note_actor})
      delete_actor = insert(:actor)

      like_data =
        File.read!("test/fixtures/mastodon-like.json")
        |> Poison.decode!()
        |> Map.put("object", note_activity.data["object"])
        |> Map.put("actor", delete_actor.data["id"])

      {:ok, %Object{data: like_data, local: false}} = Transmogrifier.handle_incoming(like_data)

      data =
        File.read!("test/fixtures/mastodon-undo-like.json")
        |> Poison.decode!()
        |> Map.put("object", like_data)
        |> Map.put("actor", like_data["actor"])

      {:ok, %Object{data: data, local: false}} = Transmogrifier.handle_incoming(data)

      assert data["actor"] == delete_actor.data["id"]
      assert data["type"] == "Undo"
      assert data["id"] == "http://mastodon.example.org/users/admin#likes/2/undo"
      assert data["object"]["id"] == "http://mastodon.example.org/users/admin#likes/2"
    end
  end
end
