defmodule MoodleNet.Plugs.UserEnabledPlug do
  import Plug.Conn
  alias MoodleNet.User

  def init(options) do
    options
  end

  def call(%{assigns: %{user: %User{info: %{"deactivated" => true}}}} = conn, _) do
    conn
    |> assign(:user, nil)
  end

  def call(conn, _) do
    conn
  end
end
