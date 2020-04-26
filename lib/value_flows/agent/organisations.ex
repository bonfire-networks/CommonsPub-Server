# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Agent.Organizations do

  alias ValueFlows.{Simulate}
  require Logger


  def organizations(signed_in_user: signed_in_user) do
    {:ok, orgs} = Organisation.Organisations.many([:default, user: signed_in_user])
    
    Enum.map(orgs, & &1 
      |> actor_to_organization
    )
  end


  def organization(id: id, signed_in_user: signed_in_user) do
    {:ok, u} = Organisation.Organisations.one([:default, id: id, user: signed_in_user])
    
    u 
      |> actor_to_organization
  end

  def actor_to_organization(u) do
    u 
    |> ValueFlows.Agent.Agents.actor_to_agent
    |> Map.put(:agent_type, :organization)
  end


end
