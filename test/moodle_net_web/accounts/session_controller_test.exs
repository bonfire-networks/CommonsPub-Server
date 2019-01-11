defmodule MoodleNetWeb.Accounts.SessionControllerTest do
  use MoodleNetWeb.ConnCase, async: true

  describe "create" do
    @tag format: :json
    test "works with json format", %{conn: conn} do
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
    @tag format: :json
    test "works with json format", %{conn: conn} do
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

  @tag format: :html
  test "works with html format", %{conn: conn} do
      user = Factory.user()
      token = Factory.oauth_token(user)

      conn = Plug.Conn.put_req_header(conn, "authorization", "Bearer #{token.hash}")

      assert ret_conn =
               conn
               |> delete("/api/v1/sessions")
               |> redirected_to(302)
  end
end

defmodule MoodleNetWeb.Accounts.SessionControllerIntegrationTest do
  use MoodleNetWeb.IntegrationCase, async: true

  @tag format: :html
  test "login works", %{conn: conn} do
    user = Factory.user()
    params = %{email: user.email, password: "password"}

    conn
    |> get("api/v1/sessions/new")
    |> follow_form(%{authorization: params})
    |> assert_response(
      status: 200,
      html: "Welcome back",
      html: user.email
    )
  end
end
