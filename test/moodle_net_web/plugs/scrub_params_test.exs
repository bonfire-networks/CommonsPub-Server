defmodule MoodleNetWeb.Plugs.ScrubParamsTest do
  use MoodleNetWeb.PlugCase

  alias MoodleNetWeb.Plugs.ScrubParams

  @moduletag method: :post

  @tag format: :json
  test "fails if params is not received with json", %{conn: conn} do
    assert %{"error_message" => "Param not found: linux", "error_code" => "missing_param"} =
             conn
             |> ScrubParams.call("linux")
             |> json_response(422)
  end

  @tag format: :html
  test "fails if params is not received with html", %{conn: conn} do
    assert conn
           |> ScrubParams.call("linux")
           |> html_response(422) =~ "Param not found: linux"
  end

  @tag format: :json
  @tag params: %{"linux" => "cool"}
  test "do nothing when the params is received", %{conn: conn} do
    assert ^conn = ScrubParams.call(conn, "linux")
  end

  @tag format: :json
  @tag params: %{"linux" => %{"empty" => ""}}
  test "set a nil when the inner params are empty", %{conn: conn} do
    assert %{params: %{"linux" => %{"empty" => nil}}} = ScrubParams.call(conn, "linux")
  end
end
