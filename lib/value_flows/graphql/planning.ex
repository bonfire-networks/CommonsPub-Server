# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.GraphQL.Planning do

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver}
  alias ValueFlows.{Simulate}
  require Logger

  import_sdl path: "lib/value_flows/graphql/schemas/planning.gql"

  def intent(%{id: id}, info) do
    {:ok, Simulate.intent()}
  end

  def all_intents(_, _, _) do
    {:ok, Simulate.long_list(&Simulate.intent/0)}
  end



end
