# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.Accounts.SessionControllerTest do
  use MoodleNetWeb.ConnCase, async: true
  @moduletag :skip

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
