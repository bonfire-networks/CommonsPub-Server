# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.Plugs.EnsureAuthenticatedPlugTest do
  use MoodleNetWeb.ConnCase, async: true
  alias MoodleNetWeb.Plugs.EnsureAuthenticatedPlug
  alias MoodleNet.Users.User

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
