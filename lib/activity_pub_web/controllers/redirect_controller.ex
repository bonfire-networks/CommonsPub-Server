# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.RedirectController do
  use ActivityPubWeb, :controller

  def actor(conn, %{"username" => username}) do
    frontend_base = MoodleNet.Config.get!(:frontend_base_url)

    case ActivityPub.Adapter.get_actor_by_username(username) do
      {:ok, %MoodleNet.Users.User{} = actor} -> redirect(conn, external: frontend_base <> "/users/" <> actor.id)
      {:ok, %MoodleNet.Collections.Collection{} = actor} -> redirect(conn, external: frontend_base <> "/collections/" <> actor.id)
      {:ok, %MoodleNet.Communities.Community{} = actor} -> redirect(conn, external: frontend_base <> "/communities/" <> actor.id)
      {:error, _e} -> redirect(conn, external: "#{frontend_base}/404")
    end
  end
end
