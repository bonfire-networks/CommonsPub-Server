defmodule MoodleNetWeb.Accounts.SessionControllerTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNet.NewFactory, as: Factory

  describe "create" do
    test "works", %{conn: conn} do
      user = Factory.user()
      params = %{"email" => user.email, "password" => "password"}

      assert %{
               "token_type" => "Bearer",
               "expires_in" => 600,
               "created_at" => _,
               "access_token" => _,
               "scope" => _,
               "refresh_token" => _
             } =
               conn
               |> post("/api/v1/sessions", %{"authorization" => params})
               |> json_response(201)
    end
  end

  describe "delete" do
    test "works", %{conn: conn} do
      user = Factory.user()
      token = Factory.oauth_token(user)

      conn = Plug.Conn.put_req_header(conn, "authorization", "Bearer #{token.hash}")

      assert "" =
               conn
               |> delete("/api/v1/sessions")
               |> response(204)

      assert %{} =
               conn
               |> delete("/api/v1/sessions")
               |> json_response(403)
    end
  end
end
