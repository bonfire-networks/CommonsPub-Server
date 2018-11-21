defmodule MoodleNetWeb.GraphQL.Context do
  @behaviour Plug

  import Plug.Conn

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
    MoodleNet.Plugs.Auth.call(conn, [])
    with current_user when not is_nil(current_user) <- conn.assigns[:current_user]
        do
          IO.inspect current_user
      {:ok, current_user}
      else
      err -> {:error, err}
    end
  end
end
