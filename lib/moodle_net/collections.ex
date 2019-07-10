# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Collections do

  import ActivityPub.Guards
  import ActivityPub.Entity, only: [local_id: 1]
  alias MoodleNet.{Policy,Repo}
  alias MoodleNet.Collections.CollectionFlag
  import MoodleNetWeb.GraphQL.MoodleNetSchema
  import Ecto.Query

  # flag(actor(), collection(), %{reason: binary()}) ::
  # {:ok, CollectionFlag.t()} | {:error, any()}
  def flag(actor, collection, attrs=%{reason: reason}) do
    attrs = flag_attrs(actor, collection, %{reason: reason})
    with :ok <- Policy.flag_collection?(actor, collection, attrs),
      do: Repo.insert(CollectionFlag.changeset(attrs))
  end

  # {:ok, CollectionFlag.t()} | {:error, Changeset.t()}
  def undo_flag(actor, collection) do
    case Repo.get_by(CollectionFlag, flag_attrs(actor, collection)) do
      nil -> {:error, :not_found}
      flag -> Repo.delete(flag)
    end
  end

  defp flag_attrs(actor, collection, base \\ %{}) do
    base
    |> Map.put(:flagged_object_id, local_id(collection))
    |> Map.put(:flagging_object_id, local_id(actor))
  end

  def flags(actor, filters \\ %{}) when has_type(actor, "Person") do
    with :ok <- Policy.list_collection_flags?(actor) do
      flags_query(filters)
      |> Repo.all()
    end
  end


  defp flags_query(filters) do
    CollectionFlag
    |> filter_open(filters)
  end
  
  # optionally filters by whether the flag is open or not

  defp filter_open(query, %{open: open}) when is_boolean(open),
    do: where(query, [f], f.open == ^open)

  defp filter_open(query, _), do: query
    
end
