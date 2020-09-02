# SPDX-License-Identifier: AGPL-3.0-only
defmodule ValueFlows.Agent.People do
  # alias ValueFlows.{Simulate}
  require Logger

  def people(signed_in_user) do
    {:ok, users} = CommonsPub.Users.many([:default, user: signed_in_user])

    Enum.map(
      users,
      &(&1
        |> actor_to_person)
    )
  end

  def person(id, signed_in_user) do
    IO.inspect(id)

    case CommonsPub.Users.one([:default, id: id, user: signed_in_user]) do
      {:ok, item} -> item |> actor_to_person
      {:error, error} -> {:error, error}
    end
  end

  def actor_to_person(u) do
    u
    |> ValueFlows.Agent.Agents.actor_to_agent()
    |> Map.put(:agent_type, :person)
  end
end
