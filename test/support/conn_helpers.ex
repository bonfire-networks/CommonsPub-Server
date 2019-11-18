# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.Test.ConnHelpers do
  require Phoenix.ConnTest
  alias Phoenix.{ConnTest, Controller}
  alias Plug.{Conn, Session}
  alias MoodleNet.Access.Token
  alias MoodleNet.Users.User
  
  @endpoint MoodleNetWeb.Endpoint

  def conn(), do: ConnTest.build_conn()

  def with_method(conn, :get), do: %{conn | method: "GET"}

  def with_method(conn, :post), do: %{conn | method: "POST"}

  def with_params(conn, %{}=params), do: %{conn | params: params}

  def with_user(conn, %User{}=user), do: Conn.assign(conn, :current_user, user)

  def with_accept_json(conn),
    do: Conn.put_req_header(conn, "accept", "application/json")

  def with_request_json(conn),
    do: Conn.put_resp_content_type(conn, "application/json")

  def with_accept_html(conn),
    do: Conn.put_req_header(conn, "accept", "text/html")

  def with_authorization(conn, %Token{id: id}),
    do: Conn.put_req_header(conn, "authorization", "Bearer #{id}")

  def json_conn(), do: conn() |> with_accept_json() |> with_request_json()

  def html_conn(), do: with_accept_html(conn())

  def user_conn(conn \\ json_conn(), user), do: with_user(conn, user)

  @default_opts [
    store: :cookie,
    key: "foobar",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt",
    log: false
  ]
  @secret String.duplicate("abcdef0123456789", 8)
  @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))

  def plugged(conn \\ json_conn()) do
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
    ConnTest.post(conn, "/api/graphql", query)
    |> ConnTest.json_response(code)
  end

  def gql_post_200(conn \\ json_conn(), query),
    do: gql_post(conn, query, 200)

  def gql_post_data(conn \\ json_conn(), query) do
    case gql_post_200(conn, query) do
      %{"data" => data, "errors" => errors} ->
        throw {:additional_errors, errors}
      %{"errors" => errors} ->
        throw {:unexpected_errors, errors}
      %{"data" => data} -> data
      other -> throw {:horribly_wrong, other}
    end
  end

  def gql_post_errors(conn \\ json_conn(), query),
    do: Map.fetch!(gql_post_200(conn, query), "errors")

end
