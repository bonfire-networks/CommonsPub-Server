# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.RedirectControllerTest do
  use MoodleNetWeb.ConnCase
  require Ecto.Query

  import MoodleNet.Test.Faking

  describe "redirect object AP IDs" do
    test "works for comments" do
      user = fake_user!()
      community = fake_community!(user)
      thread = fake_thread!(user, community, %{is_local: true})
      comment = fake_comment!(user, thread, %{is_local: true})

      Oban.drain_queue(:mn_ap_publish)
      ap_comment = ActivityPub.Object.get_by_pointer_id(comment.id)

      resp =
        build_conn()
        |> put_req_header("accept", "text/html")
        |> get(ap_comment.data["id"])
        |> html_response(302)

      assert String.contains?(resp, "redirected")
    end

    test "works for resources" do
      user = fake_user!()
      community = fake_community!(user)
      collection = fake_collection!(user, community)
      resource = fake_resource!(user, collection)

      MoodleNet.ActivityPub.Publisher.create_resource(resource)
      ap_resource = ActivityPub.Object.get_by_pointer_id(resource.id)

      resp =
        build_conn()
        |> put_req_header("accept", "text/html")
        |> get(ap_resource.data["id"])
        |> html_response(302)

      assert String.contains?(resp, "redirected")
    end
  end

  describe "redirecting actor AP IDs" do
    test "works for user" do
      user = fake_user!()
      {:ok, ap_user} = ActivityPub.Actor.get_by_local_id(user.id)

      resp =
        build_conn()
        |> put_req_header("accept", "text/html")
        |> get(ap_user.ap_id)
        |> html_response(302)

      assert String.contains?(resp, "redirected")
    end

    test "works for community" do
      community = fake_user!() |> fake_community!()
      {:ok, ap_community} = ActivityPub.Actor.get_by_local_id(community.id)

      resp =
        build_conn()
        |> put_req_header("accept", "text/html")
        |> get(ap_community.ap_id)
        |> html_response(302)

      assert String.contains?(resp, "redirected")
    end

    test "works for collections" do
      user = fake_user!()
      comm = fake_community!(user)
      coll = fake_collection!(user, comm)

      {:ok, ap_collection} = ActivityPub.Actor.get_by_local_id(coll.id)

      resp =
        build_conn()
        |> put_req_header("accept", "text/html")
        |> get(ap_collection.ap_id)
        |> html_response(302)

      assert String.contains?(resp, "redirected")
    end

    test "redirects to 404s" do
      resp =
        build_conn()
        |> put_req_header("accept", "text/html")
        |> get("pub/actors/some_name")
        |> html_response(302)

      assert String.contains?(resp, "404")
    end
  end
end
