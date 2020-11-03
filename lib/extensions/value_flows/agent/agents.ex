# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Agent.Agents do
  # alias ValueFlows.{Simulate}
  require Logger

  # TODO - change approach to allow pagination
  def agents(signed_in_user) do
    orgs = ValueFlows.Agent.Organizations.organizations(signed_in_user)
    people = ValueFlows.Agent.People.people(signed_in_user)

    orgs ++ people
  end

  # FIXME - this works but isn't elegant
  def agent(id, signed_in_user) do
    case ValueFlows.Agent.People.person(id, signed_in_user) do
      {:error, _error} ->
        ValueFlows.Agent.Organizations.organization(id, signed_in_user)

      org ->
        org
    end
  end

  def agent_to_character(a) do
    a
    |> CommonsPub.Common.maybe_put(:summary, Map.get(a, :note))
  end

  def character_to_agent(a) do
    a
    |> CommonsPub.Common.maybe_put(:note, Map.get(a, :summary))
    |> add_type()
  end

  def add_type(%CommonsPub.Users.User{} = a) do
    a
    |> Map.put(:agent_type, :person)
  end

  def add_type(%Organisation{} = a) do
    a
    |> Map.put(:agent_type, :organization)
  end

  def add_type(a) do
    a
  end
end
