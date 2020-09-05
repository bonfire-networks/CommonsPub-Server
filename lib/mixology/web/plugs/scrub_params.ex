# SPDX-License-Identifier: AGPL-3.0-only

defmodule CommonsPub.Web.Plugs.ScrubParams do
  @moduledoc """
  Halts a connection if a given param does not exist
  """
  def init(key), do: key

  def call(conn, key) do
    Phoenix.Controller.scrub_params(conn, key)
  rescue
    Phoenix.MissingParamError ->
      case Phoenix.Controller.get_format(conn) do
        "json" ->
          conn
          |> Plug.Conn.put_status(:unprocessable_entity)
          |> Phoenix.Controller.put_view(CommonsPub.Web.ErrorView)
          |> Phoenix.Controller.render(:missing_param, key: key)
          |> Plug.Conn.halt()

        _ ->
          conn
          |> Plug.Conn.put_status(:unprocessable_entity)
          |> Phoenix.Controller.fetch_flash()
          |> Phoenix.Controller.put_flash(:error, "Param not found: #{key}")
          |> Phoenix.Controller.put_layout({CommonsPub.Web.LayoutView, "app.html"})
          |> Phoenix.Controller.put_view(CommonsPub.Web.ErrorView)
          |> Phoenix.Controller.render(:missing_param, key: key)
          |> Plug.Conn.halt()
      end
  end
end
