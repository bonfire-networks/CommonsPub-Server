# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.OAuthTest do
  use MoodleNet.DataCase, async: true

  import MoodleNet.Test.Faking
  alias MoodleNet.OAuth
  alias MoodleNet.OAuth.{App, Token}

  @params %{
    "client_name" => "MoodleNetClient",
    "client_id" => "https://moodle.net/",
    "redirect_uri" => "https://moodle.net/oauth/authorization"
  }

  describe "create_app" do
    test "works" do
      assert {:ok, app = %App{}} = OAuth.create_app(@params)
      assert app.client_name == @params["client_name"]
      assert app.client_id == @params["client_id"]
      assert app.redirect_uri == @params["redirect_uri"]
      assert app.client_secret
    end

    test "validate unique client_id" do
      assert {:ok, app = %App{}} = OAuth.create_app(@params)
      assert {:error, ch} = OAuth.create_app(@params)
      assert "has already been taken" in errors_on(ch).client_id
    end

    test "validates client_id and redirect_uri has the same host" do
      assert {:error, ch} =
               @params
               |> Map.put("redirect_uri", "http://moodle.net/oauth/authorization")
               |> OAuth.create_app()

      assert "must have the same scheme, host and port that client_id" in errors_on(ch).redirect_uri

      assert {:error, ch} =
               @params
               |> Map.put("redirect_uri", "https://moodle.com/oauth/authorization")
               |> OAuth.create_app()

      assert "must have the same scheme, host and port that client_id" in errors_on(ch).redirect_uri

      assert {:error, ch} =
               @params
               |> Map.put("redirect_uri", "https://moodle.net:8888/oauth/authorization")
               |> OAuth.create_app()

      assert "must have the same scheme, host and port that client_id" in errors_on(ch).redirect_uri
    end
  end

  describe "create_token" do
    test "works" do
      user = fake_user!()
      OAuth.get_local_app()

      assert {:ok, %Token{}} = OAuth.create_token(user.id)
    end
  end

  describe "get_user_by_token" do
    test "works" do
      %{id: user_id} = fake_user!()
      assert {:ok, token} = OAuth.create_token(user_id)
      assert {:ok, %{id: ^user_id}} = OAuth.get_user_by_token(token.hash)

      assert {:error, :invalid_token} = OAuth.get_user_by_token("other_token")
      assert {:error, :token_not_found} = OAuth.get_user_by_token("1_other_token")
    end
  end

  # import MoodleNet.Factory

  # test "exchanges a auth token for an access token" do
  #   {:ok, app} =
  #     Repo.insert(
  #       App.register_changeset(%App{}, %{
  #         client_name: "client",
  #         scopes: "scope",
  #         redirect_uris: "url"
  #       })
  #     )

  #   user = insert(:user)

  #   {:ok, auth} = Authorization.create_authorization(app, user)

  #   {:ok, token} = Token.exchange_token(app, auth)

  #   assert token.app_id == app.id
  #   assert token.user_id == user.id
  #   assert String.length(token.token) > 10
  #   assert String.length(token.refresh_token) > 10

  #   auth = Repo.get(Authorization, auth.id)
  #   {:error, "already used"} = Token.exchange_token(app, auth)
  # end

  # test "create an authorization token for a valid app" do
  #   {:ok, app} =
  #     Repo.insert(
  #       App.register_changeset(%App{}, %{
  #         client_name: "client",
  #         scopes: "scope",
  #         redirect_uris: "url"
  #       })
  #     )

  #   user = insert(:user)

  #   {:ok, auth} = Authorization.create_authorization(app, user)

  #   assert auth.user_id == user.id
  #   assert auth.app_id == app.id
  #   assert String.length(auth.token) > 10
  #   assert auth.used == false
  # end

  # test "use up a token" do
  #   {:ok, app} =
  #     Repo.insert(
  #       App.register_changeset(%App{}, %{
  #         client_name: "client",
  #         scopes: "scope",
  #         redirect_uris: "url"
  #       })
  #     )

  #   user = insert(:user)

  #   {:ok, auth} = Authorization.create_authorization(app, user)

  #   {:ok, auth} = Authorization.use_token(auth)

  #   assert auth.used == true

  #   assert {:error, "already used"} == Authorization.use_token(auth)

  #   expired_auth = %Authorization{
  #     user_id: user.id,
  #     app_id: app.id,
  #     valid_until: NaiveDateTime.add(NaiveDateTime.utc_now(), -10),
  #     token: "mytoken",
  #     used: false
  #   }

  #   {:ok, expired_auth} = Repo.insert(expired_auth)

  #   assert {:error, "token expired"} == Authorization.use_token(expired_auth)
  # end
end
