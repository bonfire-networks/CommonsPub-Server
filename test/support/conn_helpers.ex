defmodule MoodleNetWeb.Test.ConnHelpers do
  require Phoenix.ConnTest
  alias Phoenix.{ConnTest, Controller}
  alias Plug.{Conn, Session}
  alias MoodleNet.OAuth.Token
  
  @endpoint MoodleNetWeb.Endpoint

  def conn(), do: ConnTest.build_conn()

  def with_accept_json(conn),
    do: Conn.put_req_header(conn, "accept", "application/json")

  def with_authorization(conn, %Token{id: id}),
    do: Conn.put_req_header(conn, "authorization", "Bearer #{id}")

  def json_conn(), do: with_accept_json(conn())

  @default_opts [
    store: :cookie,
    key: "foobar",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt",
    log: false
  ]
  @secret String.duplicate("abcdef0123456789", 8)
  @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))

  def plugged(conn \\ conn()) do
    conn
    |> Conn.put_private(:phoenix_endpoint, MoodleNetWeb.Endpoint)
    |> Map.put(:secret_key_base, @secret)
    |> Session.call(@signing_opts)
    |> Controller.accepts(["html", "json"])
    |> Conn.fetch_query_params()
    |> Conn.fetch_session()
    |> Controller.fetch_flash()
  end    
    
  def gql_post(conn \\ json_conn(), query, code) do
    ConnTest.post(conn, "/api/graphql", %{query: query})
    |> ConnTest.json_response(code)
  end

  def gql_post_200(conn \\ json_conn(), query),
    do: gql_post(conn, query, 200)

  def gql_post_data(conn \\ json_conn(), query),
    do: Map.fetch!(gql_post_200(conn, query), "data")

  def gql_post_errors(conn \\ json_conn(), query),
    do: Map.fetch!(gql_post_200(conn, query), "errors")

end
