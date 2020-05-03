# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Agent.Agents do

  alias ValueFlows.{Simulate}
  require Logger

  def agents(signed_in_user: signed_in_user) do # TODO - change approach to allow pagination

    orgs = ValueFlows.Agent.Organizations.organizations(signed_in_user: signed_in_user)
    people = ValueFlows.Agent.People.people(signed_in_user: signed_in_user)
    
    orgs ++ people

  end

  def agent(id: id, signed_in_user: signed_in_user) do # FIXME - this works but isn't elegant
  
    case ValueFlows.Agent.Organizations.organization(id: id, signed_in_user: signed_in_user) do
      {:error, error} -> ValueFlows.Agent.People.person(id: id, signed_in_user: signed_in_user)
      {org} -> org 
    end

  end


  def actor_to_agent(a) do
    a 
    |> ValueFlows.Util.maybe_put(:note, a.summary)
    # |> ValueFlows.Util.maybe_put(:note, a.summary)
  end


end
