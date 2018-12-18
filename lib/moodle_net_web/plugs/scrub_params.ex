defmodule MoodleNetWeb.Plugs.ScrubParams do
  def init(key), do: key
  def call(conn, key) do
    Phoenix.Controller.scrub_params(conn, key)
  rescue
    Phoenix.MissingParamError ->
    case Phoenix.Controller.get_format(conn) do
      "json" ->
        conn
        |> Plug.Conn.put_status(:unprocessable_entity)
        |> Phoenix.Controller.put_view(MoodleNetWeb.ErrorView)
        |> Phoenix.Controller.render(:missing_param, key: key)
        |> Plug.Conn.halt()

      _ ->
        conn
        |> Plug.Conn.put_status(:unprocessable_entity)
        |> Phoenix.Controller.fetch_flash()
        |> Phoenix.Controller.put_flash(:error, "Param not found: #{key}")
        |> Phoenix.Controller.put_layout({MoodleNetWeb.LayoutView, "app.html"})
        |> Phoenix.Controller.put_view(MoodleNetWeb.ErrorView)
        |> Phoenix.Controller.render(:missing_param, key: key)
        |> Plug.Conn.halt()
    end
  end
end
