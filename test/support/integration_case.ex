# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use MoodleNetWeb.ConnCase
      use PhoenixIntegration
    end
  end
end
