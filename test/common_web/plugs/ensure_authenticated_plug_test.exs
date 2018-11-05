defmodule MoodleNet.Plugs.EnsureAuthenticatedPlugTest do
  use MoodleNetWeb.ConnCase, async: true

  alias MoodleNet.Plugs.EnsureAuthenticatedPlug
  alias MoodleNet.Accounts.User

  test "it halts if no user is assigned", %{conn: conn} do
    conn =
      conn
      |> EnsureAuthenticatedPlug.call(%{})

    assert conn.status == 403
    assert conn.halted == true
  end

  test "it continues if a user is assigned", %{conn: conn} do
    conn =
      conn
      |> assign(:user, %User{})

    ret_conn =
      conn
      |> EnsureAuthenticatedPlug.call(%{})

    assert ret_conn == conn
  end
end
