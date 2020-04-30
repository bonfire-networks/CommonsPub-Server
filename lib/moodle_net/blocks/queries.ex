# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Blocks.Queries do

  alias MoodleNet.Blocks.Block
  import Ecto.Query

  def query(Block) do
    from b in Block, as: :block
  end

  def query(query, filters), do: filter(query(query), filters)

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  def filter(q, :deleted) do
    where q, [block: b], is_nil(b.deleted_at)
  end

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [block: b], b.id == ^id
  end

  def filter(q, {:id, {:gte, id}}) when is_binary(id) do
    where q, [block: b], b.id >= ^id
  end

  def filter(q, {:id, {:lte, id}}) when is_binary(id) do
    where q, [block: b], b.id <= ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [block: b], b.id in ^ids
  end

  def filter(q, {:context_id, id}) when is_binary(id) do
    where q, [block: b], b.context_id == ^id
  end

  def filter(q, {:context_id, ids}) when is_list(ids) do
    where q, [block: b], b.context_id in ^ids
  end

  def filter(q, {:creator_id, id}) when is_binary(id) do
    where q, [block: b], b.creator_id == ^id
  end

  def filter(q, {:creator_id, ids}) when is_list(ids) do
    where q, [block: b], b.creator_id in ^ids
  end
  
end
