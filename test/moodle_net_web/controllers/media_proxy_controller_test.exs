defmodule MoodleNetWeb.MediaProxyControllerTest do
  use MoodleNetWeb.ConnCase, async: true

  alias MoodleNet.MediaProxy.URLBuilder

  @base_url MoodleNetWeb.base_url()
  @media_path MoodleNetWeb.media_path()

  test "fetches remote media", %{conn: conn} do
    url = URLBuilder.encode("https://via.placeholder.com/150.png")

    conn = get(conn, url)
    assert conn.status == 200
    assert get_resp_header(conn, "content-type") == ["image/png; charset=utf-8"]
  end

  test "fails with an invalid signature", %{conn: conn} do
    url = "#{@base_url}/#{@media_path}/INVALID_SIG/INVALID_URL/image.png"
    assert conn |> get(url) |> response(404)
  end
end
