defmodule MoodleNet.Plugs.AuthTest do
  use MoodleNetWeb.PlugCase, async: true

  alias MoodleNet.Accounts.User
  alias MoodleNet.Factory

  alias MoodleNet.Plugs.Auth

  test "works with a current user", %{conn: conn} do
    conn = assign(conn, :current_user, %{})

    assert conn == Auth.call(conn, [])
  end

  test "works with header token", %{conn: conn} do
    %{id: user_id} = user = Factory.user()
    %{hash: hash} = Factory.oauth_token(user)

    assert %{
             halted: false,
             assigns: %{
               current_user: %User{id: ^user_id},
               auth_token: ^hash
             }
           } =
             conn
             |> put_req_header("authorization", "Bearer #{hash}")
             |> Auth.call([])
  end

  test "works with session token", %{conn: conn} do
    %{id: user_id} = user = Factory.user()
    %{hash: hash} = Factory.oauth_token(user)

    assert %{
             halted: false,
             assigns: %{
               current_user: %User{id: ^user_id},
               auth_token: ^hash
             }
           } =
             conn
             |> put_session(:auth_token, hash)
             |> Auth.call([])
  end

  test "validates token is found", %{conn: conn} do
    user = Factory.user()
    %{hash: hash} = Factory.oauth_token(user)

    assert %{
             halted: false,
             assigns: %{
               current_user: nil,
               auth_token: nil,
               auth_error: :token_not_found
             }
           } =
             conn
             |> put_req_header("authorization", "Bearer #{hash}1")
             |> Auth.call([])
  end

  test "validates token format", %{conn: conn} do
    assert %{
             halted: false,
             assigns: %{
               current_user: nil,
               auth_token: nil,
               auth_error: :invalid_token
             }
           } =
             conn
             |> put_req_header("authorization", "Bearer invalidtoken")
             |> Auth.call([])
  end

  test "validates token is sent", %{conn: conn} do
    assert %{
             halted: false,
             assigns: %{
               current_user: nil,
               auth_token: nil,
               auth_error: :no_token_sent
             }
           } =
             conn
             |> Auth.call([])
  end
end
