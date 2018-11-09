defmodule MoodleNetWeb.Accounts.SessionController do
  use MoodleNetWeb, :controller

  alias MoodleNet.{Accounts, OAuth}

  plug(ScrubParams, "authorization" when action == :create)

  def create(conn, params) do
    email = params["authorization"]["email"]
    password = params["authorization"]["password"]
    with {:ok, user} <- Accounts.authenticate_by_email_and_pass(email, password),
         {:ok, token} <- OAuth.create_token(user.id) do
      conn
      |> put_status(:created)
      |> put_view(MoodleNetWeb.OAuth.OAuthView)
      |> render("token.json", token: token)
    end
  end

  def delete(conn, params) do
    OAuth.revoke_token(conn.assigns.token)
    send_resp(conn, :no_content, "")
  end
end
