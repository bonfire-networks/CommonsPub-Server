defmodule MoodleNetWeb.OAuth.AppController do
  use MoodleNetWeb, :controller

  alias MoodleNet.OAuth

  plug(ScrubParams, "app" when action == :create)

  def create(conn, params) do
    with {:ok, app} <- OAuth.create_app(params["app"]) do
      conn
      |> put_status(:created)
      |> render(:app, app: app)
    end
  end
end
