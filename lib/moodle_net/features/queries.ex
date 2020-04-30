# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Features.Queries do

  alias MoodleNet.Features.Feature
  alias MoodleNet.Meta.PointersQueries

  import Ecto.Query

  def query(Feature) do
    from f in Feature, as: :feature
  end

  def query(query, filters), do: filter(query(query), filters)

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

  ### filter/2

  ## many

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

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [feature: f], f.id == ^id
  end

  def filter(q, {:id, {:gte, id}}) when is_binary(id) do
    where q, [feature: f], f.id >= ^id
  end

  def filter(q, {:id, {:lte, id}}) when is_binary(id) do
    where q, [feature: f], f.id <= ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [feature: f], f.id in ^ids
  end

  def filter(q, {:context_id, id}) when is_binary(id) do
    where q, [feature: f], f.context_id == ^id
  end

  def filter(q, {:context_id, ids}) when is_list(ids) do
    where q, [feature: f], f.context_id in ^ids
  end

  ## foreign fields

  def filter(q, {:table_id, ids}), do: PointersQueries.filter(q, table_id: ids)

  def filter(q, {:table, tables}), do: PointersQueries.filter(q, table: tables)

  ## ordering

  def filter(q, {:order, [desc: :created]}), do: order_by(q, [feature: f], desc: f.id)

  ## grouping and counting

  def filter(q, {:group_count, key}) when is_atom(key) do
    filter(q, group: key, count: key)
  end

  def filter(q, {:group, key}) when is_atom(key) do
    group_by q, [feature: f], field(f, ^key)
  end

  def filter(q, {:count, key}) when is_atom(key) do
    select q, [feature: f], {field(f, ^key), count(f.id)}
  end

  ## limit

  def filter(q, {:limit, n}) when is_integer(n), do: limit(q, ^n)

  ## preload

  def filter(q, {:preload, :context}), do: preload(q, [pointer: c], context: c)
  def filter(q, {:preload, :creator}), do: preload(q, [user: u], creator: u)

  ## pagination

  def filter(q, {:page, [desc: [created: %{after: a, limit: l}]]}) do
    filter(q, order: [desc: :created], limit: l + 2, id: {:lte, a})
  end

  def filter(q, {:page, [desc: [created: %{before: b, limit: l}]]}) do
    filter(q, order: [desc: :created], limit: l + 2, id: {:gte, b})
  end

  def filter(q, {:page, [desc: [created: %{limit: l}]]}) do
    filter(q, order: [desc: :created], limit: l + 1)
  end

end

