defmodule MoodleNetWeb.GraphQL.Context do
  @moduledoc """
  GraphQL Plug to add current user to the context
  """
  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    %{
      current_user: conn.assigns.current_user,
      auth_token: conn.assigns.auth_token
    }
  end
end
