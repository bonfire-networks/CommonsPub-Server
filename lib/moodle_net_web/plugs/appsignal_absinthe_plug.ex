defmodule AppsignalAbsinthePlug do
  @moduledoc """
  Appsignal plug to register GraphQL queries
  """
  alias Appsignal.Transaction

  def init(_), do: nil

  @path "/api/graphql"
  def call(%Plug.Conn{request_path: @path, method: "POST"} = conn, _) do
    Transaction.set_action("POST " <> @path)
    conn
  end

  def call(conn, _) do
    conn
  end
end
