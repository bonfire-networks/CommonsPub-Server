defmodule MoodleNetWeb.Accounts.UserController do
  use MoodleNetWeb, :controller

  alias MoodleNet.{Accounts, OAuth}
  alias MoodleNetWeb.Plugs.Auth

  plug(:accepts, ["html"] when action in [:new])

  def new(conn, _params) do
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
          |> Auth.login(user, token.hash)
          |> put_flash(:info, "Welcome!")
          # |> redirect(to: APRoutes.actor_path(conn, :show, actor.id))
          |> redirect(to: "/")
      end
    end
  end
end
