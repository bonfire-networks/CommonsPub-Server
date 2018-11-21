defmodule MoodleNetWeb.PlugCase do
  use ExUnit.CaseTemplate

  @default_opts [
    store: :cookie,
    key: "foobar",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt",
    log: false
  ]

  @secret String.duplicate("abcdef0123456789", 8)
  @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      @endpoint MoodleNetWeb.Endpoint
    end
  end

  @secret String.duplicate("abcdef0123456789", 8)
  @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))
  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MoodleNet.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(MoodleNet.Repo, {:shared, self()})
    end

    method = Map.get(tags, :method, :get)
    route = Map.get(tags, :router, "/")
    params = Map.get(tags, :params, nil)

    conn = Phoenix.ConnTest.build_conn(method, route, params)

    conn = case tags[:format] do
      :json -> Plug.Conn.put_req_header(conn, "accept", "application/json")
      :html -> Plug.Conn.put_req_header(conn, "accept", "text/html")
      _ -> conn
    end

    conn = conn
    |> Plug.Conn.put_private(:phoenix_endpoint, MoodleNetWeb.Endpoint)
    |> Map.put(:secret_key_base, @secret)
    |> Plug.Session.call(@signing_opts)
    |> Phoenix.Controller.accepts(["html", "json"])
    |> Plug.Conn.fetch_query_params()
    |> Plug.Conn.fetch_session()
    |> Phoenix.Controller.fetch_flash()

    ret = %{conn: conn}
  end
end
