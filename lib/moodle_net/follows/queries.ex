# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Follows.Queries do

  alias MoodleNet.Follows.Follow
  alias MoodleNet.Meta.PointersQueries
  alias MoodleNet.Users.User
  import MoodleNet.Common.Query, only: [match_admin: 0]
  import Ecto.Query

  def query(Follow) do
    from f in Follow, as: :follow
  end

  def query(query, filters), do: filter(query(query), filters)

  def queries(query, base_filters, data_filters, count_filters) do
    base_q = query(query, base_filters)
    data_q = filter(base_q, data_filters)
    count_q = filter(base_q, count_filters)
    {data_q, count_q}
  end

  def join_to(q, rel, jq \\ :left)

  def join_to(q, :context, jq) do
    join q, jq, [follow: f], c in assoc(f, :context), as: :pointer
  end

  @doc "Filter the query according to arbitrary criteria"
  def filter(q, filter_or_filters)

  ## by many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  ## by join

  def filter(q, {:join,{rel, jq}}), do: join_to(q, rel, jq)

  def filter(q, {:join,rel}), do: join_to(q, rel)

  ## by users
  
  def filter(q, {:user, match_admin()}) do
    filter(q, :deleted)
  end

  def filter(q, {:user, %User{id: id}}) do
    q
    |> where([follow: f], not is_nil(f.published_at) or f.creator_id == ^id)
    |> filter(:deleted)
  end

  def filter(q, {:user, nil}) do # guest
    filter q, ~w(deleted private)a
  end

  ## by status
  
  def filter(q, :deleted) do
    where q, [follow: f], is_nil(f.deleted_at)
  end

  def filter(q, :private) do
    where q, [follow: f], not is_nil(f.published_at)
  end

  # by field values

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [follow: f], f.id == ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [follow: f], f.id in ^ids
  end

  def filter(q, {:context_id, id}) when is_binary(id) do
    where q, [follow: f], f.context_id == ^id
  end

  def filter(q, {:context_id, ids}) when is_list(ids) do
    where q, [follow: f], f.context_id in ^ids
  end

  def filter(q, {:creator_id, id}) when is_binary(id) do
    where q, [follow: f], f.creator_id == ^id
  end

  def filter(q, {:creator_id, ids}) when is_list(ids) do
    where q, [follow: f], f.creator_id in ^ids
  end

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [follow: f], f.id == ^id
  end

  ## by foreign field

  def filter(q, {:table_id, ids}), do: PointersQueries.filter(q, table_id: ids)

  def filter(q, {:table, tables}), do: PointersQueries.filter(q, table: tables)

  ## by order

  def filter(q, {:order, :timeline_desc}) do
    order_by q, [follow: f], [desc: f.id]
  end

  ## by group / count

  def filter(q, {:group_count, key}) when is_atom(key) do
    filter q, group: key, count: key
  end
    
  def filter(q, {:group, key}) when is_atom(key) do
    group_by q, [follow: f], field(f, ^key)
  end

  def filter(q, {:count, key}) when is_atom(key) do
    select q, [follow: f], {field(f, ^key), count(f.id)}
  end

end
