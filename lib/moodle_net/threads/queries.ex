# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Threads.Queries do

  alias MoodleNet.Threads.{LastComment, Thread}
  alias MoodleNet.Follows.FollowerCount
  alias MoodleNet.Users.{LocalUser, User}
  import Ecto.Query

  def query(Thread) do
    from t in Thread, as: :thread
  end

  def query(query, filters) do
    filter(query(query), filters)
  end
  
  def queries(query, _page_opts, base_filters, data_filters, count_filters) do
    base_q = query(query, base_filters)
    data_q = filter(base_q, data_filters)
    count_q = filter(base_q, count_filters)
    {data_q, count_q}
  end

  def join_to(q, table_or_tables, jq \\ :left)

  ## many

  def join_to(q, tables, jq) when is_list(tables) do
    Enum.reduce(tables, q, &join_to(&2, &1, jq))
  end

  def join_to(q, :last_comment, jq) do
    join q, jq, [thread: t], c in LastComment, as: :last_comment
  end

  def join_to(q, :follower_count, jq) do
    join q, jq, [thread: t], c in FollowerCount, as: :follower_count
  end

  @doc "Filter the query according to arbitrary criteria"
  def filter(q, filter_or_filters)

  ## many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  ## by join

  def filter(q, {:join, {rel, jq}}), do: join_to(q, rel, jq)

  def filter(q, {:join, rel}), do: join_to(q, rel)

  ## by users
  
  def filter(q, {:user, %User{local_user: %LocalUser{is_instance_admin: true}}}) do
    filter(q, :deleted)
  end

  def filter(q, {:user, %User{id: id}}) do
    q
    |> where([thread: t], not is_nil(t.published_at) or t.creator_id == ^id)
    |> filter(~w(deleted hidden)a)
  end

  def filter(q, {:user, nil}) do # guest
    filter q, ~w(deleted hidden private)a
  end

  ## by status
  
  def filter(q, :deleted) do
    where q, [thread: t], is_nil(t.deleted_at)
  end

  def filter(q, :hidden) do
    where q, [thread: t], is_nil(t.hidden_at)
  end

  def filter(q, :private) do
    where q, [thread: t], not is_nil(t.published_at)
  end

  # by field values

  def filter(q, {:cursor, [followers: {:gte, [count, id]}]})
  when is_integer(count) and is_binary(id) do
    where q,[thread: t, follower_count: fc],
      (fc.count == ^count and t.id >= ^id) or fc.count > ^count
  end

  def filter(q, {:cursor, [followers: {:lte, [count, id]}]})
  when is_integer(count) and is_binary(id) do
    where q,[thread: t, follower_count: fc],
      (fc.count == ^count and t.id <= ^id) or fc.count < ^count
  end

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [thread: t], t.id == ^id
  end

  def filter(q, {:id, {:gte, id}}) when is_binary(id) do
    where q, [thread: t], t.id >= ^id
  end

  def filter(q, {:id, {:lte, id}}) when is_binary(id) do
    where q, [thread: t], t.id <= ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [thread: t], t.id in ^ids
  end

  def filter(q, {:context_id, id}) when is_binary(id) do
    where q, [thread: t], t.context_id == ^id
  end

  def filter(q, {:context_id, ids}) when is_list(ids) do
    where q, [thread: t], t.context_id in ^ids
  end

  def filter(q, {:creator_id, id}) when is_binary(id) do
    where q, [thread: t], t.creator_id == ^id
  end

  def filter(q, {:creator_id, ids}) when is_list(ids) do
    where q, [thread: t], t.creator_id in ^ids
  end

  def filter(q, {:order, [desc: :created]}) do
    order_by q, [thread: t], desc: t.id
  end

  def filter(q, {:order, [desc: :followers]}) do
    order_by q, [thread: t, follower_count: fc],
      desc: coalesce(fc.count, 0),
      desc: t.id
  end

  def filter(q, {:order, [desc: :last_comment]}) do
    order_by q, [thread: t, last_comment: lc], desc: [lc.comment_id, t.id]
  end

  def filter(q, {:group_count, key}) when is_atom(key) do
    filter q, group: key, count: key
  end

  def filter(q, {:group, key}) when is_atom(key) do
    group_by q, [thread: t], field(t, ^key)
  end

  def filter(q, {:count, key}) when is_atom(key) do
    select q, [thread: t], {field(t, ^key), count(t.id)}
  end

  def filter(q, {:preload, :last_comment}) do
    preload q, [last_comment: lc], last_comment: lc
  end

  # pagination

  def filter(q, {:limit, limit}) do
    limit(q, ^limit)
  end

  def filter(q, {:page, [desc: [created: page_opts]]}) do
    q
    |> filter(join: :last_comment, join: :follower_count, order: [desc: :created])
    |> page(page_opts, [desc: :created])
    |> select([thread: t, follower_count: fc], %{t | follower_count: coalesce(fc.count, 0)})
  end

  def filter(q, {:page, [desc: [last_comment: page_opts]]}) do
    q
    |> filter(join: :last_comment, join: :follower_count, order: [desc: :last_comment])
    |> page(page_opts, [desc: :last_comment])
    |> select([thread: t, follower_count: fc], %{t | follower_count: coalesce(fc.count, 0)})
  end

  def filter(q, {:page, [desc: [followers: page_opts]]}) do
    q
    |> filter(join: :follower_count, order: [desc: :followers])
    |> page(page_opts, [desc: :followers])
    |> select([thread: t, follower_count: fc], %{t | follower_count: coalesce(fc.count, 0)})
  end

  defp page(q, %{after: cursor, limit: limit}, [desc: :followers]) do
    filter q, cursor: [followers: {:lte, cursor}], limit: limit + 2
  end

  defp page(q, %{before: cursor, limit: limit}, [desc: :followers]) do
    filter q, cursor: [followers: {:gte, cursor}], limit: limit + 2
  end

  defp page(q, %{limit: limit}, _), do: filter(q, limit: limit + 1)

end
