# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Flags.Queries do
  alias MoodleNet.Flags.Flag
  alias MoodleNet.Meta.TableService
  alias MoodleNet.Users.User
  import Ecto.Query
  import MoodleNet.Common.Query, only: [match_admin: 0]

  def query(Flag), do: from(f in Flag, as: :flag)

  def query(query, filters), do: filter(query(query), filters)

  defp join_to(q, rel, jq \\ :left)
  defp join_to(q, :context, jq), do: join(q, jq, [flag: f], c in assoc(f, :context), as: :context)

  @doc "Filter the query according to arbitrary criteria"
  def filter(query, filter_or_filters)

  def filter(q, filters) when is_list(filters), do: Enum.reduce(filters, q, &filter(&2, &1))

  def filter(q, {:join, {rel, jq}}), do: join_to(q, rel, jq)
  def filter(q, {:join, rel}), do: join_to(q, rel)

  # no guests should be making this query
  def filter(q, {:user, match_admin()}), do: filter(q, deleted: false)
  def filter(q, {:user, %User{id: id}}), do: where(q, [flag: f], f.creator_id == ^id)

  def filter(q, {:published, nil}), do: where(q, [flag: f], is_nil(f.published_at))
  def filter(q, {:published, :not_nil}), do: where(q, [flag: f], not is_nil(f.published_at))
  def filter(q, {:published, false}), do: where(q, [flag: f], is_nil(f.published_at))
  def filter(q, {:published, true}), do: where(q, [flag: f], not is_nil(f.published_at))
  def filter(q, {:published, {:gte, %DateTime{}=time}}), do: where(q, [flag: f], f.published_at >= ^time)
  def filter(q, {:published, {:lte, %DateTime{}=time}}), do: where(q, [flag: f], f.published_at <= ^time)

  def filter(q, {:deleted, nil}), do: where(q, [flag: f], is_nil(f.deleted_at))
  def filter(q, {:deleted, :not_nil}), do: where(q, [flag: f], not is_nil(f.deleted_at))
  def filter(q, {:deleted, false}), do: where(q, [flag: f], is_nil(f.deleted_at))
  def filter(q, {:deleted, true}), do: where(q, [flag: f], not is_nil(f.deleted_at))
  def filter(q, {:deleted, {:gte, %DateTime{}=time}}), do: where(q, [flag: f], f.deleted_at >= ^time)
  def filter(q, {:deleted, {:lte, %DateTime{}=time}}), do: where(q, [flag: f], f.deleted_at <= ^time)

  def filter(q, {:id, id}) when is_binary(id), do: where(q, [flag: f], f.id == ^id)
  def filter(q, {:id, {:gte, id}}) when is_binary(id), do: where(q, [flag: f], f.id >= ^id)
  def filter(q, {:id, {:lte, id}}) when is_binary(id), do: where(q, [flag: f], f.id <= ^id)
  def filter(q, {:id, ids}) when is_list(ids), do: where(q, [flag: f], f.id in ^ids)

  def filter(q, {:context, id}) when is_binary(id), do: where(q, [flag: f], f.context_id == ^id)
  def filter(q, {:context, ids}) when is_list(ids), do: where(q, [flag: f], f.context_id in ^ids)

  def filter(q, {:creator, id}) when is_binary(id), do: where(q, [flag: f], f.creator_id == ^id)
  def filter(q, {:creator, ids}) when is_list(ids), do: where(q, [flag: f], f.creator_id in ^ids)

  def filter(q, {:community, nil}), do: where(q, [flag: f], is_nil(f.community_id))
  def filter(q, {:community, :not_nil}), do: where(q, [flag: f], not is_nil(f.community_id))
  def filter(q, {:community, id}) when is_binary(id), do: where(q, [flag: f], f.community_id == ^id)
  def filter(q, {:community, ids}) when is_list(ids), do: where(q, [flag: f], f.community_id in ^ids)

  def filter(q, {:table, id}) when is_binary(id), do: where(q, [context: c], c.table_id == ^id)
  def filter(q, {:table, table}) when is_atom(table), do: filter(q, {:table, TableService.lookup_id!(table)})
  def filter(q, {:table, tables}) when is_list(tables) do
    ids = TableService.lookup_ids!(tables)
    where(q, [context: c], c.table_id in ^ids)
  end


  def filter(q, {:page, [desc: [created: %{before: [id], limit: limit}]]}) do
    filter(q, id: {:lte, id}, limit: limit + 2, order: [desc: :created])
  end

  def filter(q, {:page, [desc: [created: %{after: [id], limit: limit}]]}) do
    filter(q, id: {:gte, id}, limit: limit + 2, order: [desc: :created])
  end

  def filter(q, {:page, [desc: [created: %{limit: limit}]]}) do
    filter(q, limit: limit + 1, order: [desc: :created])
  end


  def filter(q, {:order, [desc: :created]}), do: order_by(q, [flag: f], [desc: f.id])

  def filter(q, {:group_count, key}) when is_atom(key), do: filter(q, group: key, count: key)

  def filter(q, {:group, key}) when is_atom(key), do: group_by(q, [flag: f], field(f, ^key))

  def filter(q, {:count, key}) when is_atom(key) do
    select q, [flag: f], {field(f, ^key), count(f.id)}
  end

  def filter(q, {:limit, limit}), do: limit(q, ^limit)

  def filter(q, {:preload, :context}), do: preload(q, [context: c], context: c)
  def filter(q, {:preload, :creator}), do: preload(q, [user: u], creator: u)

  def filter(q, {:select, :id}), do: select(q, [flag: f], f.id)

end
