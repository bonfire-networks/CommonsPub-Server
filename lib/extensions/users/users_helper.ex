defmodule CommonsPub.Web.Helpers.Account do
  require Logger

  alias CommonsPub.Access
  alias CommonsPub.Users
  alias CommonsPub.Users.{Me}
  alias CommonsPub.Web.Helpers.{Profiles}

  def current_user(auth_token) do
    case CommonsPub.Access.fetch_token_and_user(auth_token) do
      {:ok, session_token} ->
        Logger.info("session_loaded")

        Profiles.prepare(session_token.user, %{icon: true, image: true, actor: true})

      {_, error} ->
        Logger.info(session_fetch_error: error)
        nil
    end
  end

  def create_session(%{login: login, password: password}) do
    case Users.one([:default, username: login]) do
      {:ok, user} ->
        session_token(user, password)

      _ ->
        # attempt with email address
        create_session(%{email: login, password: password})
    end
  end

  def create_session(%{email: email, password: password}) do
    case Users.one([:default, email: email]) do
      {:ok, user} ->
        session_token(user, password)

      _ ->
        Argon2.no_user_verify([])
        nil
    end
  end

  defp session_token(user, password) do
    with {:ok, token} <- Access.create_token(user, password) do
      %{token: token.id, current_user: Me.new(user)}
    end
  end

  # def logout(socket) do
  #   Access.hard_delete(socket.assigns.auth_token)
  # end
end
