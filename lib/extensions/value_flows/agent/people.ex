# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Agent.People do

  alias ValueFlows.{Simulate}
  require Logger


  def people(signed_in_user: signed_in_user) do
    {:ok, users} = MoodleNet.Users.many([:default, user: signed_in_user])
    
    Enum.map(users, & &1 
      |> actor_to_person
    )
  end


  def person(id: id, signed_in_user: signed_in_user) do
    {:ok, u} = MoodleNet.Users.one([:default, id: id, user: signed_in_user])
    
    u 
      |> actor_to_person
  end

  def actor_to_person(u) do
    u 
    |> ValueFlows.Agent.Agents.actor_to_agent
    |> Map.put(:agent_type, :person)
  end


end
