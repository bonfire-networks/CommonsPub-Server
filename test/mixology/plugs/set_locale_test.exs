# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Web.Plugs.SetLocaleTest do
  use CommonsPub.Web.ConnCase, async: true
  alias CommonsPub.Web.Plugs.SetLocale
  alias Plug.Conn

  @tag :skip
  test "works" do
    conn =
      html_conn()
      |> plugged()
      |> Conn.put_req_header("accept-language", "es_MX, es, en-gb;q=0.8, en;q=0.7")
      |> SetLocale.call(nil)

    assert "es_MX" == Gettext.get_locale(CommonsPub.Web.Gettext)

    # FIXME
    # conn
    # |> Conn.put_req_header("accept-language", "xyz, en-gb;q=0.8")
    # |> SetLocale.call(nil)

    # assert "en" == Gettext.get_locale(CommonsPub.Web.Gettext)

    build_conn(:get, "/?locale=es_MX", nil)
    |> Conn.fetch_query_params()
    |> Conn.put_req_header("accept-language", "en")
    |> SetLocale.call(nil)

    assert "es_MX" == Gettext.get_locale(CommonsPub.Web.Gettext)
  end
end
