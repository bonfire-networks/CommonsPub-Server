# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.RedirectController do
  use ActivityPubWeb, :controller

  def object(conn, %{"uuid" => uuid}) do
    frontend_base = MoodleNet.Config.get!(:frontend_base_url)

    with ap_id <- Routes.activity_pub_url(conn, :object, uuid),
         %ActivityPub.Object{} = object <- ActivityPub.Object.get_cached_by_ap_id(ap_id),
         {:ok, pointer} <- MoodleNet.Meta.find(object.mn_pointer_id),
         {:ok, object} <- MoodleNet.Meta.follow(pointer) do
      case object do
        %MoodleNet.Comments.Comment{} ->
          redirect(conn, external: frontend_base <> "/threads/" <> object.thread_id)

        _ ->
          redirect(conn, external: "#{frontend_base}/404")
      end
    else
      _e -> redirect(conn, external: "#{frontend_base}/404")
    end
  end

  def actor(conn, %{"username" => username}) do
    frontend_base = MoodleNet.Config.get!(:frontend_base_url)

    case ActivityPub.Adapter.get_actor_by_username(username) do
      {:ok, %MoodleNet.Users.User{} = actor} ->
        redirect(conn, external: frontend_base <> "/user/" <> actor.id)

      {:ok, %MoodleNet.Collections.Collection{} = actor} ->
        redirect(conn, external: frontend_base <> "/collections/" <> actor.id)

      {:ok, %MoodleNet.Communities.Community{} = actor} ->
        redirect(conn, external: frontend_base <> "/communities/" <> actor.id)

      {:error, _e} ->
        redirect(conn, external: "#{frontend_base}/404")
    end
  end
end
