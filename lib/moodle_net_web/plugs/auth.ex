# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
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
  alias MoodleNet.{OAuth,Users}
  alias MoodleNet.OAuth.{
    MalformedAuthorizationHeaderError,
    Token,
    TokenExpiredError,
    TokenNotFoundError,
    UserEmailNotConfirmedError,
  }
  alias MoodleNet.Users.User

  def init(opts), do: opts

  def call(%{assigns: %{current_user: %User{}}} = conn, _), do: conn

  def call(conn, opts) do
    with {:ok, token} <- get_token(conn),
         {:ok, {token, user}} <- OAuth.fetch_token_and_user(token),
         :ok <- OAuth.ensure_valid(token, get_now(opts)),
         :ok <- ensure_confirmed(user) do
      put_current_user(conn, user, token)
    else
      {:error, error} -> Conn.assign(conn, :auth_error, error)
    end
  end

  defp get_now(opts), do: Keyword.get(opts, :now) || DateTime.utc_now()

  defp ensure_confirmed(%User{confirmed_at: nil}=user),
    do: {:error, UserEmailNotConfirmedError.new(user)}

  defp ensure_confirmed(_), do: :ok

  def login(conn, user, token) do
    conn
    |> put_current_user(user, token)
    |> Conn.put_session(:auth_token, token)
    |> Conn.configure_session(renew: true)
  end

  def logout(conn), do: Conn.configure_session(conn, drop: true)

  # @specp get_token(Conn.t) :: {:ok, binary} | {:error, term}
  defp get_token(conn) do
    case Conn.get_session(conn, :auth_token) do
      nil -> get_token_by_header(conn)
      token -> {:ok, token}
    end
  end

  defp get_token_by_header(conn) do
    case Conn.get_req_header(conn, "authorization") do
      ["Bearer " <> token | _] -> {:ok, token} # take the first one if there are multiple
      [token] -> {:error, MalformedAuthorizationHeaderError.new(token)}
      _ -> {:error, TokenNotFoundError.new()}
    end
  end

  defp put_current_user(conn, %User{}=user, %Token{}=token) do
    conn
    |> Conn.assign(:current_user, user)
    |> Conn.assign(:auth_token, token)
  end

end

