# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Web.Plugs.EnsureAuthenticatedPlugTest do
  use CommonsPub.Web.ConnCase, async: true
  alias CommonsPub.Web.Plugs.EnsureAuthenticatedPlug
  alias CommonsPub.Users.User

  describe "in json format" do
    test "it continues if a user is assigned" do
      conn = assign(plugged(json_conn()), :current_user, %User{})
      assert conn == EnsureAuthenticatedPlug.call(conn, %{})
    end

    test "it halts if no user is assigned" do
      assert conn = EnsureAuthenticatedPlug.call(plugged(json_conn()), %{})
      assert conn.halted == true
      assert conn.status == 403
    end
  end

  describe "in html format" do
    test "it continues if a user is assigned" do
      conn = assign(plugged(html_conn()), :current_user, %User{})
      assert conn == EnsureAuthenticatedPlug.call(conn, %{})
    end

    test "it halts if no user is assigned" do
      conn = plugged(html_conn())
      assert conn = EnsureAuthenticatedPlug.call(conn, %{})
      assert conn.halted == true
      assert redirected_to(conn)
      assert get_flash(conn, :error)
    end
  end
end
