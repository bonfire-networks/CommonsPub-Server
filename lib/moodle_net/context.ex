defmodule MoodleNet.Context do
  @behaviour Plug

  import Plug.Conn
  alias MoodleNet.{Repo}
  alias MoodleNet.OAuth.Token

  def init(opts), do: opts


  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    with {:ok, current_user} <- authorize(conn) do
      %{current_user: current_user}
    else
      err -> %{current_user: err}
    end
  end

  defp authorize(conn) do
    token =
    case get_req_header(conn, "authorization") do
      ["Bearer " <> header] -> header
      _ -> get_session(conn, :oauth_token)
    end
    with token when not is_nil(token) <- token,
        %Token{user_id: user_id} <- Repo.get_by(Token, token: token)
        do
          IO.inspect user_id
      {:ok, user_id}
      else
      err -> {:error, err}
    end
  end
end
