# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Blocks.Queries do

  alias MoodleNet.Blocks.Block
  import Ecto.Query

  def query(Block), do: from(b in Block, as: :block)

  def query(query, filters), do: filter(query(query), filters)

  def filter(q, filters) when is_list(filters), do: Enum.reduce(filters, q, &filter(&2, &1))

  def filter(q, {:deleted, nil}), do: where(q, [block: b], is_nil(b.deleted_at))
  def filter(q, {:deleted, :not_nil}), do: where(q, [block: b], not is_nil(b.deleted_at))
  def filter(q, {:deleted, false}), do: where(q, [block: b], is_nil(b.deleted_at))
  def filter(q, {:deleted, true}), do: where(q, [block: b], not is_nil(b.deleted_at))
  def filter(q, {:deleted, {:gte, %DateTime{}=time}}), do: where(q, [block: b], b.deleted_at >= ^time)
  def filter(q, {:deleted, {:lte, %DateTime{}=time}}), do: where(q, [block: b], b.deleted_at <= ^time)

  def filter(q, {:id, id}) when is_binary(id), do: where(q, [block: b], b.id == ^id)
  def filter(q, {:id, {:gte, id}}) when is_binary(id), do: where(q, [block: b], b.id >= ^id)
  def filter(q, {:id, {:lte, id}}) when is_binary(id), do: where(q, [block: b], b.id <= ^id)
  def filter(q, {:id, ids}) when is_list(ids), do: where(q, [block: b], b.id in ^ids)

  def filter(q, {:context, id}) when is_binary(id), do: where(q, [block: b], b.context_id == ^id)
  def filter(q, {:context, ids}) when is_list(ids), do: where(q, [block: b], b.context_id in ^ids)

  def filter(q, {:creator, id}) when is_binary(id), do: where(q, [block: b], b.creator_id == ^id)
  def filter(q, {:creator, ids}) when is_list(ids), do: where(q, [block: b], b.creator_id in ^ids)
  
  def filter(q, {:preload, :context}), do: preload(q, [context: c], context: c)
  def filter(q, {:preload, :creator}), do: preload(q, [user: u], creator: u)

  def filter(q, {:select, :id}), do: select(q, [block: b], b.id)

end
