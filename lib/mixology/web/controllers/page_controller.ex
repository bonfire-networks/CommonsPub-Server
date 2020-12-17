# SPDX-License-Identifier: AGPL-3.0-only

defmodule CommonsPub.Web.PageController do
  use CommonsPub.Web, :controller

  def index(conn, _params) do
    url =
      if System.get_env("LIVEVIEW_ENABLED", "true") == "true" do
        "/instance"
      else
        Bonfire.Common.Config.get!(:frontend_base_url)
      end

    conn
    |> put_status(:moved_permanently)
    |> redirect(external: url)
  end

  def api(conn, _params) do
    conn
    |> redirect(external: "/api/explore")
  end

  def logout(conn, _params) do
    conn
    |> CommonsPub.Web.Plugs.Auth.logout()
    |> redirect(external: "/")
  end

  def confirm_email(conn, params) do
    conn
    |> CommonsPub.Web.Plugs.Auth.confirm_email(params["token"])
    |> redirect(external: "/")
  end
end
