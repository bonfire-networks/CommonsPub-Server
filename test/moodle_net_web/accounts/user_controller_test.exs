# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.Accounts.UserControllerTest do
  use MoodleNetWeb.ConnCase

  describe "create" do
    @tag format: :json
    test "works", %{conn: conn} do
      params = Factory.attributes(:user)
      MoodleNet.Accounts.add_email_to_whitelist(params["email"])

      assert ret =
               conn
               |> post("/api/v1/users", %{"user" => params})
               |> json_response(201)

      assert %{
               "user" => user,
               "token" => token
               # "actor" => actor
             } = ret

      # assert actor["preferred_username"] == params["username"]
      assert user["email"] == params["email"]

      assert %{"token_type" => "Bearer", "access_token" => _} = token
    end

    @tag format: :json
    test "returns errors", %{conn: conn} do
      params = Factory.attributes(:user, password: "short")

      MoodleNet.Accounts.add_email_to_whitelist(params["email"])
      assert ret =
               conn
               |> post("/api/v1/users", %{"user" => params})
               |> json_response(422)

      assert %{
               "error_code" => "validation_errors",
               "error_message" => "Validation errors",
               "errors" => %{"password" => ["should be at least 6 character(s)"]}
             } = ret
    end
  end
end
