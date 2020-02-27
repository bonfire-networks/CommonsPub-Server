# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.Plugs.AuthTest do
  use MoodleNetWeb.ConnCase, async: true

  import MoodleNet.Test.Faking
  alias Plug.Conn
  alias MoodleNet.Access.{
    MalformedAuthorizationHeaderError,
    TokenExpiredError,
    TokenNotFoundError,
  }
  alias MoodleNetWeb.Plugs.Auth

  defp strip_token(token), do: Map.drop(token, [:user])
  defp strip_user(user) do
    local = Map.delete(user.local_user, :email_confirm_tokens)
    user
    |> Map.drop([:actor, :is_disabled, :is_public])
    |> Map.put(:local_user, local)
  end
    

  test "works with a current user" do
    user = fake_user!(%{}, confirm_email: true)
    conn = assign(plugged(), :current_user, user)
    assert conn == Auth.call(conn, [])
  end

  test "works with header token" do
    user = fake_user!(%{}, confirm_email: true)
    token = fake_token!(user)
    assert conn =
      plugged()
      |> with_authorization(token)
      |> Auth.call([])
    assert conn.halted == false
    assert strip_user(conn.assigns.current_user) == strip_user(user)
    assert strip_token(conn.assigns.auth_token) == strip_token(token)
  end

  test "works with session token" do
    user = fake_user!(%{}, confirm_email: true)
    token = fake_token!(user)
    assert conn =
      plugged()
      |> Conn.put_session(:auth_token, token.id)
      |> Auth.call([])
    assert conn.halted == false
    assert strip_user(conn.assigns.current_user) == strip_user(user)
    assert strip_token(conn.assigns.auth_token) == strip_token(token)
    assert conn.assigns[:auth_error] == nil
  end

  test "validates token is sent" do
    assert conn = Auth.call(plugged(), [])
    assert conn.halted == false
    assert conn.assigns[:current_user] == nil
    assert conn.assigns[:auth_token] == nil
    assert conn.assigns.auth_error == TokenNotFoundError.new()
  end

  test "validates token is found" do
    user = fake_user!(%{}, confirm_email: true)
    token = fake_token!(user)
    assert conn =
      plugged()
      |> Conn.put_session(:auth_token, token.id <> token.id)
      |> Auth.call([])
    assert conn.halted == false
    assert conn.assigns[:current_user] == nil
    assert conn.assigns[:auth_token] == nil
    assert conn.assigns.auth_error == TokenNotFoundError.new()
  end

  test "validates token format" do
    assert conn =
      plugged()
      |> Conn.put_req_header("authorization", "abcdef")
      |> Auth.call([])
    assert conn.halted == false
    assert conn.assigns[:current_user] == nil
    assert conn.assigns[:auth_token] == nil
    assert conn.assigns.auth_error == MalformedAuthorizationHeaderError.new()
  end

  test "validates token has not expired" do
    user = fake_user!(%{}, confirm_email: true)
    token = fake_token!(user)
    then = DateTime.add(DateTime.utc_now(), 3600 * 24 * 15)
    assert conn =
      plugged()
      |> with_authorization(token)
      |> Auth.call([now: then])
    assert conn.halted == false
    assert conn.assigns[:current_user] == nil
    assert conn.assigns[:auth_token] == nil
    assert conn.assigns.auth_error == TokenExpiredError.new()
  end

end
