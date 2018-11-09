defmodule MoodleNet.Plugs.EnsureAuthenticatedPlug do
  import Plug.Conn

  def init(options), do: options

  def call(%{assigns: %{user: %{}}} = conn, _), do: conn

  def call(conn, _) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(403, Jason.encode!(%{error: "Invalid credentials."}))
    |> halt()
  end
end
