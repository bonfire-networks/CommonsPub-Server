# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.Plugs.DigestPlug do
  alias Plug.Conn
  require Logger

  def read_body(conn, opts) do
    {:ok, body, conn} = Conn.read_body(conn, opts)
    digest = "SHA-256=" <> (:crypto.hash(:sha256, body) |> Base.encode64())
    {:ok, body, Conn.assign(conn, :digest, digest)}
  end
end
