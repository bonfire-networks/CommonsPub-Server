# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Peers.Queries do
  alias MoodleNet.Peers.Peer
  import Ecto.Query

  def query(Peer), do: from p in Peer, as: :peer

  def query(query, filters), do: filter(query(query), filters)

  def filter(q, filter_or_filters)

  def filter(q, filters) when is_list(filters), do: Enum.reduce(filters, q, &filter(&2, &1))

  def filter(q, {:deleted, nil}), do: where(q, [peer: p], is_nil(p.deleted_at))
  def filter(q, {:deleted, :not_nil}), do: where(q, [peer: p], not is_nil(p.deleted_at))
  def filter(q, {:deleted, false}), do: where(q, [peer: p], is_nil(p.deleted_at))
  def filter(q, {:deleted, true}), do: where(q, [peer: p], not is_nil(p.deleted_at))
  def filter(q, {:deleted, {:gte, %DateTime{}=time}}), do: where(q, [peer: p], p.deleted_at >= ^time)
  def filter(q, {:deleted, {:lte, %DateTime{}=time}}), do: where(q, [peer: p], p.deleted_at <= ^time)

  def filter(q, {:disabled, nil}), do: where(q, [peer: p], is_nil(p.disabled_at))
  def filter(q, {:disabled, :not_nil}), do: where(q, [peer: p], not is_nil(p.disabled_at))
  def filter(q, {:disabled, false}), do: where(q, [peer: p], is_nil(p.disabled_at))
  def filter(q, {:disabled, true}), do: where(q, [peer: p], not is_nil(p.disabled_at))
  def filter(q, {:disabled, {:gte, %DateTime{}=time}}), do: where(q, [peer: p], p.disabled_at >= ^time)
  def filter(q, {:disabled, {:lte, %DateTime{}=time}}), do: where(q, [peer: p], p.disabled_at <= ^time)

  def filter(q, {:id, id}) when is_binary(id), do: where(q, [peer: p], p.id == ^id)
  def filter(q, {:id, {:gte, id}}) when is_binary(id), do: where(q, [peer: p], p.id >= ^id)
  def filter(q, {:id, {:lte, id}}) when is_binary(id), do: where(q, [peer: p], p.id <= ^id)
  def filter(q, {:id, ids}) when is_list(ids), do: where(q, [peer: p], p.id in ^ids)

end
