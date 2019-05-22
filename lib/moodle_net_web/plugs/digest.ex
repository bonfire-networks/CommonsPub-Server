defmodule MoodleNetWeb.Plugs.DigestPlug do
  @moduledoc """
  Generates the digest for the body.

  Not used at the moment
  """
  alias Plug.Conn
  require Logger

  def read_body(conn, opts) do
    {:ok, body, conn} = Conn.read_body(conn, opts)
    digest = "SHA-256=" <> (:crypto.hash(:sha256, body) |> Base.encode64())
    {:ok, body, Conn.assign(conn, :digest, digest)}
  end
end
