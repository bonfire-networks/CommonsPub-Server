# SPDX-License-Identifier: AGPL-3.0-only

defmodule CommonsPub.Web.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use CommonsPub.Web.ConnCase
      use PhoenixIntegration
    end
  end
end
