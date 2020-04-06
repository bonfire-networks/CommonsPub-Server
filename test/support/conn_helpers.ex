# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.Test.ConnHelpers do
  require Phoenix.ConnTest
  alias Phoenix.{ConnTest, Controller}
  alias Plug.{Conn, Session}
  alias MoodleNet.Access.Token
  alias MoodleNet.Users.User
  import ExUnit.Assertions

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

  def token_conn(conn \\ json_conn(), token), do: with_authorization(conn, token)

  @default_opts [
    store: :cookie,
    key: "foobar",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt",
    log: false
  ]
  @secret String.duplicate("abcdef0123456789", 8)
  @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))

  def plugged(conn) do
    conn
    |> Conn.put_private(:phoenix_endpoint, MoodleNetWeb.Endpoint)
    |> Map.put(:secret_key_base, @secret)
    |> Session.call(@signing_opts)
    |> Controller.accepts(["html", "json"])
    |> Conn.fetch_query_params()
    |> Conn.fetch_session()
    |> Controller.fetch_flash()
  end

  def gql_post(conn, query, code) do
    ConnTest.post(conn, "/api/graphql", query)
    |> ConnTest.json_response(code)
  end

  def gql_post_200(conn, query),
    do: gql_post(conn, query, 200)

  def gql_post_data(conn, query) do
    case gql_post_200(conn, query) do
      %{"data" => _data, "errors" => errors} ->
        throw {:additional_errors, errors}
      %{"errors" => errors} ->
        throw {:unexpected_errors, errors}
      %{"data" => data} -> data
        # IO.inspect(client_received: data)
        data
      other -> throw {:horribly_wrong, other}
    end
  end

  def grumble_post_data(query, conn, vars \\ %{}, name \\ "test") do
    query = Grumble.PP.to_string(query)
    vars = camel_map(vars)
    # IO.puts("query: " <> query)
    # IO.inspect(vars: vars)
    query = %{
      query: query,
      variables: vars,
      operationName: name,
    }
    gql_post_data(conn, query)
  end

  def grumble_post_key(query, conn, key, vars \\ %{}, name \\ "test") do
    key = camel(key)
    assert %{^key => val} = grumble_post_data(query, conn, vars, name)
    val
  end

  def gql_post_errors(conn \\ json_conn(), query),
    do: Map.fetch!(gql_post_200(conn, query), :errors)

  def grumble_post_errors(query, conn, vars \\ %{}, name \\ "test") do
    query = Grumble.PP.to_string(query)
    vars = camel_map(vars)
    # IO.inspect(query: query)
    # IO.inspect(vars: vars)
    query = %{
      query: query,
      variables: vars,
      operationName: name,
    }
   Map.fetch!(gql_post_200(conn, query), "errors")
  end

  @doc false
  def camel_map(%{}=vars) do
    Enum.reduce(vars, %{}, fn {k,v}, acc -> Map.put(acc, camel(k), v) end)
  end

  @doc false
  def camel(atom) when is_atom(atom), do: camel(Atom.to_string(atom))
  def camel(binary) when is_binary(binary), do: Recase.to_camel(binary)

  @doc false
  def uncamel_map(%{}=map) do
    Enum.reduce(map, %{}, fn {k,v}, acc -> Map.put(acc, uncamel(k), v) end)
  end

  @doc false
  def uncamel(atom) when is_atom(atom), do: atom
  def uncamel("__typeName"), do: :typename
  def uncamel(bin) when is_binary(bin), do: String.to_existing_atom(Recase.to_snake(bin))

end
