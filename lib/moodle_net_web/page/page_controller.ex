# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.PageController do
  use MoodleNetWeb, :controller

  def index(conn, _params) do
    url =
      if System.get_env("LIVEVIEW_ENABLED", "true") == "true" do
        "/instance"
      else
        Application.fetch_env!(:moodle_net, :frontend_base_url)
      end

    conn
    |> put_status(:moved_permanently)
    |> redirect(external: url)
  end

  def api(conn, _params) do
    conn
    |> redirect(external: "/api/explore")
  end

  def logout(conn, _params) do
    conn
    |> MoodleNetWeb.Plugs.Auth.logout()
    |> redirect(external: "/")
  end

  def confirm_email(conn, params) do
    conn
    |> MoodleNetWeb.Plugs.Auth.confirm_email(params["token"])
    |> redirect(external: "/")
  end
end
