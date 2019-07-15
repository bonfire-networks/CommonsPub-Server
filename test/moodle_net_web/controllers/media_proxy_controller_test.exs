defmodule MoodleNetWeb.MediaProxyControllerTest do
  use MoodleNetWeb.ConnCase, async: true

  alias MoodleNet.MediaProxy.URLBuilder

  test "fetches remote media", %{conn: conn} do
    url = URLBuilder.encode("https://via.placeholder.com/150.png")

    conn = get(conn, url)
    assert conn.status == 200
    assert get_resp_header(conn, "content-type") == ["image/png; charset=utf-8"]
  end
end
