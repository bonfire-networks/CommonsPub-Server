# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphqlCase do
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
      use Phoenix.ConnTest
      import MoodleNetWeb.GraphqlCase
      import MoodleNetWeb.Router.Helpers
      # The default endpoint for testing
      @endpoint MoodleNetWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MoodleNet.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(MoodleNet.Repo, {:shared, self()})
    end
    {:ok, %{}}
  end
 
  def json_conn() do
    Phoenix.ConnTest.build_conn()
    |> Plug.Conn.put_req_header("accept", "application/json")
  end

end
