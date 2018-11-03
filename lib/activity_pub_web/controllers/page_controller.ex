defmodule ActivityPubWeb.PageController do
  use ActivityPubWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
