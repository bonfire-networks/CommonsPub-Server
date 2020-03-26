# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.GraphQL.Observation do

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver}
  require Logger

  import_sdl path: "lib/valueflows/graphql/schemas/observation.gql"
  # import_sdl path: "lib/valueflows/graphql/schemas/plan.gql"
  # import_sdl path: "lib/valueflows/graphql/schemas/planning.gql"
  # import_sdl path: "lib/valueflows/graphql/schemas/recipe.gql"
  # import_sdl path: "lib/valueflows/graphql/schemas/proposal.gql"
  # import_sdl path: "lib/valueflows/graphql/schemas/scenario.gql"
  # import_sdl path: "lib/valueflows/graphql/schemas/agreement.gql"
  # import_sdl path: "lib/valueflows/graphql/schemas/appreciation.gql"
  # import_sdl path: "lib/valueflows/graphql/schemas/claim.gql"

end
