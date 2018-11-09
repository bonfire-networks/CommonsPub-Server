defmodule MoodleNetWeb.Accounts.UserController do
  use MoodleNetWeb, :controller

  alias MoodleNet.{Accounts, OAuth}

  plug(ScrubParams, "user" when action == :create)

  def create(conn, params) do
    with {:ok, %{actor: actor, user: user}} <- Accounts.register_user(params["user"]),
         {:ok, token} <- OAuth.create_token(user.id) do
      conn
      |> put_status(:created)
      |> render(:registration, token: token, actor: actor, user: user)
    end
  end
end
