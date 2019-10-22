# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.OAuth.OAuthControllerTest do
  use MoodleNetWeb.ConnCase

  alias MoodleNet.{OAuth, Repo}
  alias MoodleNet.OAuth.{Authorization, Token}
  import MoodleNet.Test.Faking

  defp client_id(), do: Map.fetch!(config(), :client_id)
  defp redirect_uri(), do: Map.fetch!(config(), :redirect_uri)
  defp config(), do: Application.get_env(:moodle_net, OAuth)

  test "returns error with invalid credentials" do
    # user = fake_user!()

    # post(html_conn(), "/oauth/authorize", %{
    #   "authorization" => %{
    #     "email" => user.email,
    #     "password" => "wrong_password",
    #     "client_id" => app.client_id,
    #     "redirect_uri" => app.redirect_uri,
    #     "state" => "statepassed"
    #   }
    # })
    # |> json_response(401)
  end

  test "redirects with oauth authorization" do
    # user = fake_user!()

    # conn =
    #   user_conn()
    #   |> post("/oauth/authorize", %{
    #     "authorization" => %{
    #       "email" => user.email,
    #       "password" => "password",
    #       "client_id" => app.client_id,
    #       "redirect_uri" => app.redirect_uri,
    #       "state" => "statepassed"
    #     }
    #   })

    # target = redirected_to(conn)
    # assert target =~ app.redirect_uri

    # query = URI.parse(target).query |> URI.query_decoder() |> Map.new()

    # assert %{"state" => "statepassed", "code" => code} = query
    # assert Repo.get_by(Authorization, hash: code)
  end

  test "issues a token for an all-body request" do
    # user = Factory.user()
    # app = Factory.oauth_app()

    # {:ok, auth} = Authorization.create_authorization(app, user)

    # conn =
    #   build_conn()
    #   |> post("/oauth/token", %{
    #     "grant_type" => "authorization_code",
    #     "code" => auth.token,
    #     "redirect_uri" => redirect_uri(),
    #     "client_id" => client_id(),
    #     "client_secret" => app.client_secret,
    #   })

    # assert %{"access_token" => token} = json_response(conn, 200)
    # assert Repo.get_by(Token, token: token)
  end

  test "issues a token for request with HTTP basic auth client credentials" do
    # user = Factory.user()
    # app = Factory.oauth_app()

    # {:ok, auth} = Authorization.create_authorization(app, user)

    # app_encoded =
    #   (URI.encode_www_form(app.client_id) <> ":" <> URI.encode_www_form(app.client_secret))
    #   |> Base.encode64()

    # conn =
    #   build_conn()
    #   |> put_req_header("authorization", "Basic " <> app_encoded)
    #   |> post("/oauth/token", %{
    #     "grant_type" => "authorization_code",
    #     "code" => auth.token,
    #     "redirect_uri" => app.redirect_uris
    #   })

    # assert %{"access_token" => token} = json_response(conn, 200)
    # assert Repo.get_by(Token, token: token)
  end

  test "rejects token exchange with invalid client credentials" do
    # user = Factory.user()
    # app = Factory.oauth_app()

    # {:ok, auth} = Authorization.create_authorization(app, user)

    # conn =
    #   build_conn()
    #   |> put_req_header("authorization", "Basic JTIxOiVGMCU5RiVBNCVCNwo=")
    #   |> post("/oauth/token", %{
    #     "grant_type" => "authorization_code",
    #     "code" => auth.token,
    #     "redirect_uri" => app.redirect_uris
    #   })

    # assert resp = json_response(conn, 400)
    # assert %{"error" => _} = resp
    # refute Map.has_key?(resp, "access_token")
  end

  test "rejects an invalid authorization code" do
    # app = Factory.oauth_app()

    # conn =
    #   build_conn()
    #   |> post("/oauth/token", %{
    #     "grant_type" => "authorization_code",
    #     "code" => "Imobviouslyinvalid",
    #     "redirect_uri" => app.redirect_uris,
    #     "client_id" => app.client_id,
    #     "client_secret" => app.client_secret
    #   })

    # assert resp = json_response(conn, 400)
    # assert %{"error" => _} = json_response(conn, 400)
    # refute Map.has_key?(resp, "access_token")
  end
end
