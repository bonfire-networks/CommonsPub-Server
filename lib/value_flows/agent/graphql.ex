# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Agent.GraphQL do

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver}
  alias ValueFlows.{Simulate}
  require Logger

  import_sdl path: "lib/value_flows/graphql/schemas/agent.gql"

  # fake data
  def all_agents(_, _, _) do
    {:ok, Simulate.long_list(&Simulate.agent/0)}
  end

  def agent(%{id: id}, info) do
    {:ok, Simulate.agent()}
  end

  # support for inteface type
  def agent_resolve_type(%{agent_type: :person}, _), do: :person
  def agent_resolve_type(%{agent_type: :organization}, _), do: :organization

  # def person_is_type_of(_), do: true
  # def organization_is_type_of(_), do: true

  # proper resolvers

  def users(%{}, info) do
    {:ok, users} = MoodleNet.Users.many([:default, user: MoodleNet.GraphQL.current_user(info)])
    
    {:ok, 
      Enum.map(users, & &1 |> ValueFlows.Util.maybe_put(:note, &1.summary))
    }
  end


  def user(%{id: id}, info) do
    {:ok, u} = MoodleNet.Users.one([:default, id: id, user: MoodleNet.GraphQL.current_user(info)])
    
    {:ok, 
      u 
      |> ValueFlows.Util.maybe_put(:note, u.summary)
    }
  end


end
