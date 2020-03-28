# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.GraphQL.Measurement do

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver}
  alias ValueFlows.{Simulate}
  require Logger

  import_sdl path: "lib/valueflows/graphql/schemas/measurement.gql"

  def all_units(_, _, _) do
    {:ok, Simulate.long_list(&Simulate.unit/0)}
  end

  def unit(%{id: id}, info) do
    {:ok, Simulate.unit()}
  end


end
