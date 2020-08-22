# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Scenario.GraphQL do
  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver}
  require Logger

  # import_sdl path: "lib/value_flows/graphql/schemas/scenario.gql"
end
