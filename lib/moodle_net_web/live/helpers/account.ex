defmodule MoodleNetWeb.Helpers.Account do
  alias MoodleNet.Access
  alias MoodleNet.Users
  alias MoodleNet.Users.{Me}
  alias MoodleNetWeb.Helpers.{Profiles}

  def current_user_or(
        fallback,
        %{
          "auth_token" => auth_token,
          "current_user" => current_user
        },
        preload
      ) do
    Profiles.prepare(current_user, preload)
  end

  def current_user_or(
        fallback,
        %{
          "auth_token" => auth_token
        },
        preload
      ) do
    with {:ok, session_token} <- MoodleNet.Access.fetch_token_and_user(auth_token) do
      current_user_or(
        fallback,
        %{
          "auth_token" => auth_token,
          "current_user" => session_token.user
        },
        preload
      )
    else
      {:error, _} ->
        fallback
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
end
