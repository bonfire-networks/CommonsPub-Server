defmodule MoodleNet.Plugs.UserEnabledPlugTest do
  use MoodleNetWeb.ConnCase, async: true

  alias MoodleNet.Plugs.UserEnabledPlug
  import MoodleNet.Factory

  test "doesn't do anything if the user isn't set", %{conn: conn} do
    ret_conn =
      conn
      |> UserEnabledPlug.call(%{})

    assert ret_conn == conn
  end

  test "with a user that is deactivated, it removes that user", %{conn: conn} do
    user = insert(:user, info: %{"deactivated" => true})

    conn =
      conn
      |> assign(:user, user)
      |> UserEnabledPlug.call(%{})

    assert conn.assigns.user == nil
  end

  test "with a user that is not deactivated, it does nothing", %{conn: conn} do
    user = insert(:user)

    conn =
      conn
      |> assign(:user, user)

    ret_conn =
      conn
      |> UserEnabledPlug.call(%{})

    assert conn == ret_conn
  end
end
