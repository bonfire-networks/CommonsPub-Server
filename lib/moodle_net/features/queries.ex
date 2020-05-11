# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Features.Queries do

  alias MoodleNet.Features.Feature
  alias MoodleNet.Meta.{PointersQueries, TableService}

  import Ecto.Query

  def query(Feature), do: from(f in Feature, as: :feature)

  def query(query, filters), do: filter(query(query), filters)

  defp join_to(q, spec, join_qualifier \\ :left)
  defp join_to(q, specs, jq) when is_list(specs), do: Enum.reduce(specs, q, &join_to(&2, &1, jq))
  defp join_to(q, :context, jq), do: join(q, jq, [feature: f], c in assoc(f, :context), as: :context)
  defp join_to(q, :creator, jq), do: join(q, jq, [feature: f], c in assoc(f, :creator), as: :user)

  ### filter/2

  def filter(q, filters) when is_list(filters), do: Enum.reduce(filters, q, &filter(&2, &1))

  def filter(q, {:join, {join, qual}}), do: join_to(q, join, qual)
  def filter(q, {:join, join}), do: join_to(q, join)

  def filter(q, {:deleted, nil}), do: where(q, [feature: f], is_nil(f.deleted_at))
  def filter(q, {:deleted, :not_nil}), do: where(q, [feature: f], not is_nil(f.deleted_at))
  def filter(q, {:deleted, false}), do: where(q, [feature: f], is_nil(f.deleted_at))
  def filter(q, {:deleted, true}), do: where(q, [feature: f], not is_nil(f.deleted_at))
  def filter(q, {:deleted, {:gte, %DateTime{}=time}}), do: where(q, [feature: f], f.deleted_at >= ^time)
  def filter(q, {:deleted, {:lte, %DateTime{}=time}}), do: where(q, [feature: f], f.deleted_at <= ^time)

  def filter(q, {:id, id}) when is_binary(id), do: where(q, [feature: f], f.id == ^id)
  def filter(q, {:id, {:gte, id}}) when is_binary(id), do: where(q, [feature: f], f.id >= ^id)
  def filter(q, {:id, {:lte, id}}) when is_binary(id), do: where(q, [feature: f], f.id <= ^id)
  def filter(q, {:id, ids}) when is_list(ids), do: where(q, [feature: f], f.id in ^ids)

  def filter(q, {:context, id}) when is_binary(id), do: where(q, [feature: f], f.context_id == ^id)
  def filter(q, {:context, ids}) when is_list(ids), do: where(q, [feature: f], f.context_id in ^ids)

  def filter(q, {:table, id}) when is_binary(id), do: where(q, [context: c], c.table_id == ^id)
  def filter(q, {:table, table}) when is_atom(table), do: filter(q, {:table, TableService.lookup_id!(table)})
  def filter(q, {:table, tables}) when is_list(tables) do
    ids = TableService.lookup_ids!(tables)
    where(q, [context: c], c.table_id in ^ids)
  end


  def filter(q, {:page, [desc: [created: %{after: [a], limit: l}]]}) do
    filter(q, order: [desc: :created], limit: l + 2, id: {:lte, a})
  end

  def filter(q, {:page, [desc: [created: %{before: [b], limit: l}]]}) do
    filter(q, order: [desc: :created], limit: l + 2, id: {:gte, b})
  end

  def filter(q, {:page, [desc: [created: %{limit: l}]]}), do: filter(q, order: [desc: :created], limit: l + 1)


  def filter(q, {:order, [desc: :created]}), do: order_by(q, [feature: f], desc: f.id)

  def filter(q, {:group_count, key}) when is_atom(key), do: filter(q, group: key, count: key)

  def filter(q, {:group, key}) when is_atom(key), do: group_by(q, [feature: f], field(f, ^key))

  def filter(q, {:count, key}) when is_atom(key), do: select(q, [feature: f], {field(f, ^key), count(f.id)})

  def filter(q, {:limit, n}) when is_integer(n), do: limit(q, ^n)

  def filter(q, {:preload, :context}), do: preload(q, [context: c], context: c)
  def filter(q, {:preload, :creator}), do: preload(q, [user: u], creator: u)

end

