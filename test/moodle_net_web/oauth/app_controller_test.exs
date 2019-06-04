# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.OAuth.AppControllerTest do
  use MoodleNetWeb.ConnCase, async: true

  @moduletag :skip

  describe "create" do
    test "creates app", %{conn: conn} do
      params = Factory.attributes(:oauth_app)

      assert app =
               conn
               |> post("/oauth/apps/", %{"app" => params})
               |> json_response(201)

      assert app["client_name"] == params["client_name"]
      assert app["client_id"] == params["client_id"]
      assert app["redirect_uri"] == params["redirect_uri"]
      assert app["website"] == params["website"]
      assert app["scopes"] == params["scopes"]
      assert app["client_secret"]
    end

    test "returns errors", %{conn: conn} do
      params = Factory.attributes(:oauth_app, redirect_uri: "https://very_random.com")

      assert error =
               conn
               |> post("/oauth/apps/", %{"app" => params})
               |> json_response(422)

      assert error == %{
               "error_code" => "validation_errors",
               "error_message" => "Validation errors",
               "errors" => %{
                 "redirect_uri" => ["must have the same scheme, host and port that client_id"]
               }
             }

      assert error =
               conn
               |> post("/oauth/apps/")
               |> json_response(422)

      assert error == %{"error_code" => "missing_param", "error_message" => "Param not found: app"}
    end
  end
end
