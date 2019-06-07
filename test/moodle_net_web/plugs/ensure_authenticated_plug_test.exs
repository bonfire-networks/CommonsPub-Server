# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.Plugs.EnsureAuthenticatedPlugTest do
  use MoodleNetWeb.PlugCase, async: true

  alias MoodleNetWeb.Plugs.EnsureAuthenticatedPlug
  alias MoodleNet.Accounts.User

  describe "in json format" do
    @tag format: :json
    test "it halts if no user is assigned", %{conn: conn} do
      assert %{status: 403, halted: true} = EnsureAuthenticatedPlug.call(conn, %{})
    end

    @tag format: :json
    test "it continues if a user is assigned", %{conn: conn} do
      conn = assign(conn, :current_user, %User{})

      assert conn == EnsureAuthenticatedPlug.call(conn, %{})
    end
  end

  describe "in html format" do
    @tag format: :html
    test "it halts if no user is assigned", %{conn: conn} do
      assert conn = EnsureAuthenticatedPlug.call(conn, %{})
      assert conn.halted
      assert redirected_to(conn)
      assert get_flash(conn, :error)
    end

    @tag format: :html
    test "it continues if a user is assigned", %{conn: conn} do
      conn = assign(conn, :current_user, %User{})

      assert conn == EnsureAuthenticatedPlug.call(conn, %{})
    end
  end
end
