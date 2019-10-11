# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.Plugs.AuthTest do
  use MoodleNetWeb.ConnCase, async: true

  import MoodleNet.Test.Faking
  alias Plug.Conn
  alias MoodleNet.OAuth.{
    MalformedAuthorizationHeaderError,
    TokenExpiredError,
    TokenNotFoundError,
  }
  alias MoodleNetWeb.Plugs.Auth

  defp strip_user(user), do: Map.drop(user, [:actor, :email_confirm_tokens])

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
    assert conn.assigns.auth_token == token
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
    assert conn.assigns.auth_token == token
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
    assert conn.assigns.auth_error == MalformedAuthorizationHeaderError.new("abcdef")
  end

  test "validates token has not expired" do
    user = fake_user!(%{}, confirm_email: true)
    token = fake_token!(user)
    then = DateTime.add(DateTime.utc_now(), 60 * 11)
    assert conn =
      plugged()
      |> with_authorization(token)
      |> Auth.call([now: then])
    assert conn.halted == false
    assert conn.assigns[:current_user] == nil
    assert conn.assigns[:auth_token] == nil
    assert conn.assigns.auth_error == TokenExpiredError.new(token)
  end

end
