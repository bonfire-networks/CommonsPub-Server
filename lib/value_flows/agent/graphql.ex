# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Agent.GraphQL do

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver}
  alias ValueFlows.{Simulate}
  require Logger

  import_sdl path: "lib/value_flows/graphql/schemas/agent.gql"


  def all_agents(_, _, _) do
    {:ok, Simulate.long_list(&Simulate.agent/0)}
  end

  def agent(%{id: id}, info) do
    {:ok, Simulate.agent()}
  end



end
