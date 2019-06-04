# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.OAuth.AppController do
  use MoodleNetWeb, :controller

  alias MoodleNet.OAuth

  plug(ScrubParams, "app" when action == :create)

  def create(conn, params) do
    with {:ok, app} <- OAuth.create_app(params["app"]) do
      conn
      |> put_status(:created)
      |> render(:app, app: app)
    end
  end
end
