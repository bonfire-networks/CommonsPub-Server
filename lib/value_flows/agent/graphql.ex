# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Agent.GraphQL do

  use Absinthe.Schema.Notation
  alias MoodleNetWeb.GraphQL.{CommonResolver}
  alias ValueFlows.{Simulate}
  require Logger

  # import_sdl path: "lib/value_flows/graphql/schemas/agent.gql"


  # fake data
  # def all_agents(_, _) do
  #   {:ok, Simulate.long_list(&Simulate.agent/0)}
  # end

  # def agent(%{id: id}, info) do
  #   {:ok, Simulate.agent()}
  # end

  # support for inteface type
  def agent_resolve_type(%{agent_type: :person}, _), do: :person
  def agent_resolve_type(%{agent_type: :organization}, _), do: :organization
  def agent_resolve_type(%{agent_type: nil}, _), do: :person

  # def person_is_type_of(_), do: true
  # def organization_is_type_of(_), do: true

  # proper resolvers

  def people(%{}, info) do # TODO: pagination
    {:ok, 
      ValueFlows.Agent.People.people(signed_in_user: MoodleNet.GraphQL.current_user(info))
    }
  end


  def person(%{id: id}, info) do    
    {:ok, 
      ValueFlows.Agent.People.person(id: id, signed_in_user: MoodleNet.GraphQL.current_user(info))
    }
  end

  def organizations(%{}, info) do # TODO: pagination
    {:ok, 
      ValueFlows.Agent.Organizations.organizations(signed_in_user: MoodleNet.GraphQL.current_user(info))
    }
  end


  def organization(%{id: id}, info) do    
    {:ok, 
      ValueFlows.Agent.Organizations.organization(id: id, signed_in_user: MoodleNet.GraphQL.current_user(info))
    }
  end

  def all_agents(%{}, info) do
    {:ok, 
      ValueFlows.Agent.Agents.agents(signed_in_user: MoodleNet.GraphQL.current_user(info))
    }
  end

    def agent(%{id: id}, info) do
      {:ok, 
      ValueFlows.Agent.Agents.agent(id: id, signed_in_user: MoodleNet.GraphQL.current_user(info))
    }
    end


end
