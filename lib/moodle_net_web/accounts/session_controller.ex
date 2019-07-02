# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.Accounts.SessionController do
  use MoodleNetWeb, :controller

  alias MoodleNet.{Accounts, OAuth}
  alias MoodleNetWeb.Plugs.Auth

  plug(ScrubParams, "authorization" when action == :create)

  def create(conn, params) do
    email = params["authorization"]["email"]
    password = params["authorization"]["password"]

    with {:ok, user} <- Accounts.authenticate_by_email_and_pass(email, password),
         {:ok, token} <- OAuth.create_token(user.id) do
      case get_format(conn) do
        "json" ->
          conn
          |> put_status(:created)
          |> put_view(MoodleNetWeb.OAuth.OAuthView)
          |> render("token.json", token: token)

        "html" ->
          conn
          |> Auth.login(user, token.hash)
          |> put_flash(:info, "Welcome back!")
          # |> redirect(to: APRoutes.actor_path(conn, :show, user.actor_id))
          |> redirect(to: "/")
      end
    end
  end

  def delete(conn, _params) do
    OAuth.revoke_token(conn.assigns.auth_token)

    case get_format(conn) do
      "json" ->
        send_resp(conn, :no_content, "")

      "html" ->
        conn
        |> Auth.logout()
        |> put_flash(:info, "See you soon!")
        |> redirect(to: "/")
    end
  end
end
