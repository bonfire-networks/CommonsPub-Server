# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.ActivityPubControllerTest do
  use MoodleNetWeb.ConnCase

  import MoodleNet.Test.Faking
  @public_uri "https://www.w3.org/ns/activitystreams#Public"

  describe "object" do
    test "works for activities" do
      actor = fake_ap_actor!()
      context = "blabla"
      object = %{"content" => "content", "type" => "Note"}
      to = ["https://testing.kawen.dance/users/karen"]
      additional = %{"cc" => [@public_uri]}

      params = %{
        actor: actor,
        context: context,
        object: object,
        to: to,
        additional: additional
      }

      {:ok, activity} = ActivityPub.create(params)

      uuid =
        String.split(activity.data["id"], "/")
        |> List.last()

      resp =
        build_conn()
        |> put_req_header("accept", "application/json")
        |> get("/pub/objects/#{uuid}")
        |> json_response(200)

      assert resp["@context"]
      assert resp["type"] == "Create"
    end

    test "works for objects" do
      actor = fake_ap_actor!()
      context = "blabla"
      object = %{"content" => "content", "type" => "Note"}
      to = ["https://testing.kawen.dance/users/karen"]
      additional = %{"cc" => [@public_uri]}

      params = %{
        actor: actor,
        context: context,
        object: object,
        to: to,
        additional: additional
      }

      {:ok, activity} = ActivityPub.create(params)

      uuid =
        String.split(activity.data["object"], "/")
        |> List.last()

      resp =
        build_conn()
        |> put_req_header("accept", "application/json")
        |> get("/pub/objects/#{uuid}")
        |> json_response(200)

      assert resp["@context"]
      assert resp["type"] == "Note"
    end
  end

  describe "actor" do
    test "works for actors" do
      actor = fake_actor!()

      resp =
        build_conn()
        |> put_req_header("accept", "application/json")
        |> get("pub/actors/#{actor.preferred_username}")
        |> json_response(200)

      assert resp["@context"]
      assert resp["preferredUsername"] == actor.preferred_username
      assert resp["url"] == resp["id"]
    end
  end
end
