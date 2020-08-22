# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Agent.Agents do
  alias ValueFlows.{Simulate}
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
      {:error, error} ->
        ValueFlows.Agent.Organizations.organization(id, signed_in_user)

      org ->
        org
    end
  end

  def actor_to_agent(a) do
    a
    |> ValueFlows.Util.maybe_put(:note, a.summary)

    # |> ValueFlows.Util.maybe_put(:note, a.summary)
  end
end
