defmodule MoodleNetWeb.Plugs.EnsureAuthenticatedPlug do
  import Plug.Conn
  import Phoenix.Controller

  def init(options), do: options

  def call(%{assigns: %{current_user: %{}}} = conn, _), do: conn

  def call(conn, _) do
    case get_format(conn) do
      "json" ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{error: "Invalid credentials."}))
        |> halt()
      "html" ->
        conn
        |> put_flash(:error, "You must be logged in to access to this page")
        |> redirect(to: "/")
        |> halt()
    end
  end
end
