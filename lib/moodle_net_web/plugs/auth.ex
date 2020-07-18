# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.Plugs.Auth do
  @moduledoc """
  This plug makes sure the user is authenticated.

  It tries the following:

  1. Seek a `current_user` in the connection assigns (useful for tests).
    1. Returns the connection unchanged
  2. Check for a string token provided by the user
    1. Session `auth_token`
    2. HTTP `authorization` header
      1. if malformed, returns the connection with modified assigns
        * `auth_error`, a MalformedAuthorizationHeaderError
    3. else returns the connection with modified assigns
        * `auth_error`, a TokenNotFoundError
  3. Pulls the token and the user it pertains to from the database
    4. Verifies the token has not expired
      1. else returns the connection with modified assigns
        * `auth_error`, a TokenExpiredError
    5. Verifies the user has confirmed their email address
      1. else returns the connection with modified assigns
        * `auth_error`, a UserEmailNotConfirmedError
    6. Returns the connection with modified assigns:
      * `current_user`, a User
      * `auth_token`, a Token
  """
  alias Plug.Conn
  alias MoodleNet.Access

  alias MoodleNet.Access.{
    MalformedAuthorizationHeaderError,
    Token,
    TokenNotFoundError
  }

  alias MoodleNet.Users.User

  def init(opts), do: opts

  # def call(%{assigns: %{current_user: %User{}}} = conn, _), do: conn

  def call(conn, opts) do
    case Map.get(conn.assigns, :current_user) do
      nil ->
        try_login(conn, opts)

      _ ->
        conn
    end
  end

  defp get_now(opts) do
    if Map.has_key?(opts, :now) do
      Keyword.get(opts, :now)
    else
      DateTime.utc_now()
    end
  end

  def try_login(conn, opts \\ %{}) do
    with {:ok, token} <- get_token(conn) do
      login(conn, token, opts)
    else
      {:error, error} -> auth_error(conn, error)
    end
  end

  def login(conn, %Token{} = token, opts) do
    with :ok <- Access.verify_token(token, get_now(opts)) do
      logged_in(conn, token.user, token)
    else
      {:error, error} -> auth_error(conn, error)
    end
  end

  def login(conn, token, opts \\ %{}) do
    with {:ok, token} <- Access.fetch_token_and_user(token) do
      login(conn, token)
    else
      {:error, error} -> auth_error(conn, error)
    end
  end

  defp auth_error(conn, error) do
    Conn.assign(conn, :auth_error, error)
    |> clear_session
  end

  defp logged_in(conn, user, %Token{} = token) do
    conn
    |> put_current_user(user, token)
    |> Conn.put_session(:auth_token, token.id)
    |> Conn.configure_session(renew: true)
  end

  def logout(conn) do
    with {:ok, token} <- get_token(conn),
         {:ok, token} <- Access.fetch_token_and_user(token) do
      Access.hard_delete(token)
    end

    conn
    |> clear_session
  end

  # @specp get_token(Conn.t) :: {:ok, binary} | {:error, term}
  defp get_token(conn) do
    case Conn.get_session(conn, :auth_token) do
      nil -> get_token_by_header(conn)
      token -> {:ok, token}
    end
  end

  defp get_token_by_header(conn) do
    case Conn.get_req_header(conn, "authorization") do
      # take the first one if there are multiple
      ["Bearer " <> token | _] -> {:ok, token}
      [_token] -> {:error, MalformedAuthorizationHeaderError.new()}
      _ -> get_token_by_param(conn)
    end
  end

  defp get_token_by_param(conn) do
    case conn.params["auth_token"] do
      nil -> {:error, TokenNotFoundError.new()}
      token -> {:ok, token}
    end
  end

  defp put_current_user(conn, %MoodleNet.Users.Me{} = user, token) do
    put_current_user(conn, user.user, token)
  end

  defp put_current_user(conn, %User{} = user, token) do
    conn
    |> Conn.assign(:current_user, user)
    |> Conn.assign(:auth_token, token)
  end

  defp clear_session(conn) do
    conn
    |> Conn.delete_session(:auth_token)
    |> Conn.assign(:current_user, nil)
    |> Conn.assign(:auth_token, nil)
  end

  def confirm_email(conn, token) do
    {ok, res} = MoodleNetWeb.GraphQL.UsersResolver.confirm_email(%{token: token}, %{})
    # IO.inspect(res)
    login(conn, res.token, %{})
  end
end
