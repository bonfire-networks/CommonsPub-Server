# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Features.Queries do

  alias MoodleNet.Features.Feature
  alias MoodleNet.Meta.PointersQueries

  import Ecto.Query

  def query(Feature) do
    from f in Feature, as: :feature
  end

  def query(query, filters), do: filter(query(query), filters)

  def queries(query, base_filters, data_filters, count_filters) do
    base_q = query(query, base_filters)
    data_q = filter(base_q, data_filters)
    count_q = filter(base_q, count_filters)
    {data_q, count_q}
  end

  def join_to(q, spec, join_qualifier \\ :left)

  def join_to(q, specs, jq) when is_list(specs) do
    Enum.reduce(specs, q, &join_to(&2, &1, jq))
  end

  def join_to(q, :context, jq) do
    join q, jq, [feature: f], c in assoc(f, :context), as: :pointer
  end

  def join_to(q, :creator, jq) do
    join q, jq, [feature: f], c in assoc(f, :creator), as: :user
  end

  def prefetch(q, :context), do: preload(q, [pointer: c], context: c)
  def prefetch(q, :creator), do: preload(q, [user: u], creator: u)

  ### filter/2

  ## by many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  ## by join

  def filter(q, {:join, {join, qual}}), do: join_to(q, join, qual)
  def filter(q, {:join, join}), do: join_to(q, join)

  ## by status
  
  def filter(q, :deleted) do
    where q, [feature: f], is_nil(f.deleted_at)
  end

  ## by field values

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [feature: f], f.id in ^ids
  end

  def filter(q, {:context_id, id}) when is_binary(id) do
    where q, [feature: f], f.context_id == ^id
  end

  def filter(q, {:context_id, ids}) when is_list(ids) do
    where q, [feature: f], f.context_id in ^ids
  end

  ## by foreign field

  def filter(q, {:table_id, ids}), do: PointersQueries.filter(q, table_id: ids)

  def filter(q, {:table, tables}), do: PointersQueries.filter(q, table: tables)

  ## by ordering

  def filter(q, {:order, :timeline_desc}), do: order_by(q, [feature: f], desc: f.id)

  ## by prefetch
  def filter(q, {:preload, preload}), do: prefetch(q, preload)
end

