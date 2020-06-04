# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.Plugs.SetLocaleTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNetWeb.Plugs.SetLocale
  alias Plug.Conn

  @tag :skip
  test "works" do
    conn =
      html_conn()
      |> plugged()
      |> Conn.put_req_header("accept-language", "es_MX, es, en-gb;q=0.8, en;q=0.7")
      |> SetLocale.call(nil)

    assert "es_MX" == Gettext.get_locale(MoodleNetWeb.Gettext)

    # FIXME
    # conn
    # |> Conn.put_req_header("accept-language", "xyz, en-gb;q=0.8")
    # |> SetLocale.call(nil)

    # assert "en" == Gettext.get_locale(MoodleNetWeb.Gettext)

    build_conn(:get, "/?locale=es_MX", nil)
    |> Conn.fetch_query_params()
    |> Conn.put_req_header("accept-language", "en")
    |> SetLocale.call(nil)

    assert "es_MX" == Gettext.get_locale(MoodleNetWeb.Gettext)
  end

end
