# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Actors.Queries do

  alias MoodleNet.Actors.Actor
  import Ecto.Query

  def query(Actor), do: from(a in Actor, as: :actor)

  def query(query, filters), do: filter(query(query), filters)

  @doc "Filter the query according to arbitrary criteria"
  def filter(query, filter_or_filters)

  def filter(q, filters) when is_list(filters), do: Enum.reduce(filters, q, &filter(&2, &1))

  def filter(q, {:id, id}) when is_binary(id), do: where(q, [actor: a], a.id == ^id)
  def filter(q, {:id, ids}) when is_list(ids), do: where(q, [actor: a], a.id in ^ids)

  def filter(q, {:peer, nil}), do: where(q, [actor: a], is_nil(a.peer_id))
  def filter(q, {:peer, :not_nil}), do: where(q, [actor: a], not is_nil(a.peer_id))
  def filter(q, {:peer, id}) when is_binary(id), do: where(q, [actor: a], a.peer_id == ^id)
  def filter(q, {:peer, ids}) when is_list(ids), do: where(q, [actor: a], a.peer_id in ^ids)

  def filter(q, {:username, name}) when is_binary(name), do: where(q, [actor: a], a.preferred_username == ^name)
  def filter(q, {:username, names}) when is_list(names), do: where(q, [actor: a], a.preferred_username in ^names)

end
