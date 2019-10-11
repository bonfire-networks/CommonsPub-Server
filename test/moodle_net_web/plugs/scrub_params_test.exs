# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.Plugs.ScrubParamsTest do
  use MoodleNetWeb.ConnCase
  alias MoodleNetWeb.Plugs.ScrubParams

  test "fails if params is not received with json" do
    conn =
      json_conn()
      |> with_method(:post)
      |> plugged()
    assert %{"error_message" => "Param not found: linux", "error_code" => "missing_param"} =
             conn
             |> ScrubParams.call("linux")
             |> json_response(422)
  end

  test "fails if params is not received with html" do
    conn =
      html_conn()
      |> with_method(:post)
      |> plugged()
    assert conn
           |> ScrubParams.call("linux")
           |> html_response(422) =~ "Param not found: linux"
  end

  test "do nothing when the params is received" do
    conn =
      json_conn()
      |> with_method(:post)
      |> with_params(%{"linux" => "cool"})
      |> plugged()
    assert ^conn = ScrubParams.call(conn, "linux")
  end

  test "set a nil when the inner params are empty" do
    conn =
      html_conn()
      |> with_method(:post)
      |> with_params(%{"linux" => %{"empty" => ""}})
      |> plugged()
    assert %{params: %{"linux" => %{"empty" => nil}}} = ScrubParams.call(conn, "linux")
  end

end
