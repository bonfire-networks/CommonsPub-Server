defmodule MoodleNetWeb.PageController do
  @moduledoc """
  Standard page controller created by Phoenix generator
  """
  use MoodleNetWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
