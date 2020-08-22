# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.ConnCase do
  @moduledoc """
  This case template is for graphql tests. It is a slimmed down
  version of ConnCase.
  """

  use ExUnit.CaseTemplate
  require Phoenix.ConnTest

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest
      import MoodleNetWeb.ConnCase
      import MoodleNetWeb.Test.ConnHelpers
      import MoodleNetWeb.Router.Helpers
      # The default endpoint for testing
      @endpoint MoodleNetWeb.Endpoint
    end
  end

  setup tags do
    Cachex.clear(:ap_actor_cache)
    Cachex.clear(:ap_object_cache)
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MoodleNet.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(MoodleNet.Repo, {:shared, self()})
    end

    {:ok, %{}}
  end
end
