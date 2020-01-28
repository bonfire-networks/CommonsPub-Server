# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.Plugs.Static do
  use Plug.Builder

  plug(:not_found)

  def not_found(conn, _) do
    send_resp(conn, 404, "file not found")
  end
end
