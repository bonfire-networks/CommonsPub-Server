# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.Plugs.Auth do
  @moduledoc """
  Authentication plug.
  Checks if the token is valid and load the user
  """
  import Plug.Conn

  def init(_opts), do: nil

  def call(%{assigns: %{current_user: %{}}} = conn, _), do: conn

  def call(conn, _) do
    with {:ok, token} <- get_token(conn),
         {:ok, user} <- MoodleNet.OAuth.get_user_by_token(token) do
      user = MoodleNet.Users.preload_actor(user)
      put_current_user(conn, user, token)
    else
      {:error, error} ->
        conn
        |> assign(:current_user, nil)
        |> assign(:auth_token, nil)
        |> assign(:auth_error, error)
    end
  end

  defp get_token(conn) do
    get_token_by_session(conn) || get_token_by_header(conn) || {:error, :no_token_sent}
  end

  defp get_token_by_session(conn) do
    if token = get_session(conn, :auth_token) do
      {:ok, token}
    end
  end

  defp get_token_by_header(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> {:ok, token}
      _ -> nil
    end
  end

  def login(conn, user, token) do
    conn
    |> put_current_user(user, token)
    |> put_session(:auth_token, token)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  defp put_current_user(conn, user, token) do
    conn
    |> assign(:current_user, user)
    |> assign(:auth_token, token)
  end
end
