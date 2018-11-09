defmodule MoodleNet.Plugs.OAuthPlug do
  import Plug.Conn
  alias MoodleNet.Accounts.User

  def init(opts), do: opts

  def call(%{assigns: %{user: %User{}}} = conn, _), do: conn

  def call(conn, _) do
    with {:ok, token} <- get_token(conn),
         {:ok, user} <- MoodleNet.OAuth.get_user_by_token(token) do
           conn
           |> assign(:user, user)
           |> assign(:token, token)
    else
      error -> 
           conn
           |> assign(:user, nil)
           |> assign(:token, nil)
           |> assign(:oauth_error, error)
    end
  end

  defp get_token(conn) do
    get_token_by_session(conn) || get_token_by_header(conn) || {:error, :no_token}
  end

  defp get_token_by_session(conn) do
    if token = get_session(conn, :oauth_token) do
      {:ok, token}
    end
  end

  defp get_token_by_header(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> {:ok, token}
      _ -> nil
    end
  end
end
