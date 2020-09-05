defmodule CommonsPub.Web.Live.Plug do
  @moduledoc """
  LiveView Plug
  """

  import Plug.Conn
  import Phoenix.Controller

  def init(options), do: options

  def call(conn, _) do
    if System.get_env("LIVEVIEW_ENABLED", "true") != "true" do
      conn
      |> redirect(to: "/")
      |> halt()
    else
      conn
    end
  end
end
