defmodule MoodleNetWeb.MediaProxyControllerTest do
  use MoodleNetWeb.ConnCase, async: true

  alias MoodleNet.MediaProxy.URLBuilder

  test "fetches remote media", %{conn: conn} do
    url = URLBuilder.encode("https://via.placeholder.com/150.png")
    assert conn |> get(url) |> response(200)
  end
end
