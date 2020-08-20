# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.Plugs.EnsureAdminPlug do
  @moduledoc """
  Halts the conn if the user is not authenticated
  """
  import Plug.Conn
  import Phoenix.Controller
  alias MoodleNet.Users.User

  def init(options), do: options

  def call(%{assigns: %{current_user: %User{local_user: %{is_instance_admin: true}}}} = conn, _),
    do: conn

  def call(conn, _) do
    case get_format(conn) do
      "json" ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{error: "Invalid authorisation."}))
        |> halt()

      "html" ->
        conn
        |> put_flash(:error, "You must be an admin to access to this page")
        |> redirect(to: "/~")
        |> halt()
    end
  end
end
