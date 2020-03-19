# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Actors.Queries do

  alias MoodleNet.Actors.Actor
  import Ecto.Query

  def query(Actor) do
    from a in Actor, as: :actor
  end

  def query(query, filters), do: filter(query(query), filters)

  @doc "Filter the query according to arbitrary criteria"
  def filter(q, filter_or_filters)

  ## by many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  ## by status

  def filter(q, :local) do
    where q, [actor: a], not is_nil(a.peer_id)
  end

  def filter(q, :remote) do
    where q, [actor: a], is_nil(a.peer_id)
  end

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [actor: a], a.id == ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [actor: a], a.id in ^ids
  end

  def filter(q, {:peer_id, id}) when is_binary(id) do
    where q, [actor: a], a.peer_id == ^id
  end

  def filter(q, {:peer_id, ids}) when is_list(ids) do
    where q, [actor: a], a.peer_id in ^ids
  end

  def filter(q, {:username, username}) when is_binary(username) do
    where q, [actor: a], a.preferred_username == ^username
  end

  def filter(q, {:username, usernames}) when is_list(usernames) do
    where q, [actor: a], a.preferred_username in ^usernames
  end

end
