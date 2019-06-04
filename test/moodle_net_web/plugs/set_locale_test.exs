# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.Plugs.SetLocaleTest do
  use MoodleNetWeb.PlugCase, async: true

  alias MoodleNetWeb.Plugs.SetLocale

  test "works", %{conn: conn} do
    conn
    |> Plug.Conn.put_req_header("accept-language", "es, en-gb;q=0.8, en;q=0.7")
    |> SetLocale.call(nil)

    assert "es" == Gettext.get_locale(MoodleNetWeb.Gettext)

    conn
    |> Plug.Conn.put_req_header("accept-language", "de, en-gb;q=0.8")
    |> SetLocale.call(nil)

    assert "en" == Gettext.get_locale(MoodleNetWeb.Gettext)

    build_conn(:get, "/?locale=es", nil)
    |> Plug.Conn.fetch_query_params()
    |> Plug.Conn.put_req_header("accept-language", "en")
    |> SetLocale.call(nil)

    assert "es" == Gettext.get_locale(MoodleNetWeb.Gettext)
  end
end
