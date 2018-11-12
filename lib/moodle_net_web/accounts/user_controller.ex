defmodule MoodleNetWeb.Accounts.UserController do
  use MoodleNetWeb, :controller

  alias MoodleNet.{Accounts, OAuth}

  plug(:accepts, ["html"] when action in [:new])

  def new(conn, params) do
    render(conn, "new.html")
  end

  plug(ScrubParams, "user" when action == :create)

  def create(conn, params) do
    with {:ok, %{actor: actor, user: user}} <- Accounts.register_user(params["user"]),
         {:ok, token} <- OAuth.create_token(user.id) do
      case get_format(conn) do
        "json" ->
          conn
          |> put_status(:created)
          |> render(:registration, token: token, actor: actor, user: user)

        "html" ->
          conn
          |> put_status(:created)
          |> text("OK")
      end
    end
  end
end
