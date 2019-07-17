# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common do

  import ActivityPub.Guards
  import ActivityPub.Entity, only: [local_id: 1]
  alias MoodleNet.{Policy,Repo}
  import MoodleNetWeb.GraphQL.MoodleNetSchema
  import Ecto.Query

  def flag(model, policy, actor, thing, attrs) do
    attrs = flag_attrs(actor, thing, attrs)
    with :ok <- apply(Policy, policy, [actor, thing, attrs]),
      do: Repo.insert(apply(model, :changeset, [attrs]))
  end

  def undo_flag(model, actor, thing) do
    case Repo.get_by(model, flag_attrs(actor, thing)) do
      nil -> {:error, :not_found}
      flag -> Repo.delete(flag)
    end
  end

  def flags(model, policy, actor, filters \\ %{}) when has_type(actor, "Person") do
    with :ok <- apply(Policy, policy, [actor]),
      do: Repo.all(flags_query(model, filters))
  end

  defp flag_attrs(actor, thing, base \\ %{}) do
    base
    |> Map.put(:flagged_object_id, local_id(thing))
    |> Map.put(:flagging_object_id, local_id(actor))
  end

  defp flags_query(model, filters), do: filter_open(model, filters)
  
  # optionally filters by whether the flag is open or not

  defp filter_open(query, %{open: open}) when is_boolean(open),
    do: where(query, [f], f.open == ^open)

  defp filter_open(query, _), do: query

end
