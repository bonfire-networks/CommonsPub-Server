# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Peers.Queries do
  alias MoodleNet.Peers.Peer
  import Ecto.Query

  def query(Peer), do: from p in Peer, as: :peer

  def query(query, filters), do: filter(query(query), filters)

  def filter(q, filter_or_filters)

  ## by many
  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  ## by status

  def filter(q, :deleted) do
    where q, [peer: p], is_nil(p.deleted_at)
  end

  def filter(q, :disabled) do
    where q, [peer: p], not is_nil(p.disabled_at)
  end

  ## by field values
  def filter(q, {:id, id}) when is_binary(id) do
    where q, [peer: p], p.id == ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [peer: p], p.id in ^ids
  end
end
