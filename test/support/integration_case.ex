defmodule MoodleNetWeb.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use MoodleNetWeb.ConnCase
      use PhoenixIntegration
    end
  end
end
