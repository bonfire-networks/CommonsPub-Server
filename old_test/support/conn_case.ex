defmodule MoodleNetWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import MoodleNetWeb.Router.Helpers

      alias MoodleNet.NewFactory, as: Factory

      # The default endpoint for testing
      @endpoint MoodleNetWeb.Endpoint
    end
  end

  setup tags do
    Cachex.clear(:user_cache)
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MoodleNet.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(MoodleNet.Repo, {:shared, self()})
    end

    conn = Phoenix.ConnTest.build_conn()

    accept_header = case tags[:format] do
      :json ->
        "application/json"
      :json_ld ->
        "application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\""
      _ ->
        "text/html"
    end

    conn = Plug.Conn.put_req_header(conn, "accept", accept_header)

    {:ok, conn: conn}
  end
end
