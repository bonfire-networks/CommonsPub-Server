# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule AppsignalAbsinthePlug do
  alias Appsignal.Transaction

  def init(_), do: nil

  @path "/api/graphql"
  def call(%Plug.Conn{request_path: @path, method: "POST"} = conn, _) do
    Transaction.set_action("POST " <> @path)
    conn
  end

  def call(conn, _) do
    conn
  end
end
