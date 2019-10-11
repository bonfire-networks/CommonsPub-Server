# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.Plugs.SetLocaleTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNetWeb.Plugs.SetLocale
  alias Plug.Conn

  test "works" do
    conn =
      html_conn()
      |> plugged()
      |> Conn.put_req_header("accept-language", "es, en-gb;q=0.8, en;q=0.7")
      |> SetLocale.call(nil)

    assert "es" == Gettext.get_locale(MoodleNetWeb.Gettext)

    conn
    |> Conn.put_req_header("accept-language", "de, en-gb;q=0.8")
    |> SetLocale.call(nil)

    assert "en" == Gettext.get_locale(MoodleNetWeb.Gettext)

    build_conn(:get, "/?locale=es", nil)
    |> Conn.fetch_query_params()
    |> Conn.put_req_header("accept-language", "en")
    |> SetLocale.call(nil)

    assert "es" == Gettext.get_locale(MoodleNetWeb.Gettext)
  end

end
