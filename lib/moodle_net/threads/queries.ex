# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Threads.Queries do

  alias MoodleNet.Threads.{LastComment, Thread}
  alias MoodleNet.Follows.FollowerCount
  alias MoodleNet.Users.User
  import Ecto.Query
  import MoodleNet.Common.Query, only: [match_admin: 0]

  def query(Thread), do: from(t in Thread, as: :thread)

  def query(query, filters), do: filter(query(query), filters)
  

  defp join_to(q, table_or_tables, jq \\ :left)

  defp join_to(q, tables, jq) when is_list(tables), do: Enum.reduce(tables, q, &join_to(&2, &1, jq))
  defp join_to(q, :last_comment, jq), do: join(q, jq, [thread: t], c in LastComment, as: :last_comment)
  defp join_to(q, :follower_count, jq) do
    join q, jq, [thread: t],
      c in FollowerCount, as: :follower_count,
      on: t.id == c.context_id
  end

  @doc "Filter the query according to arbitrary criteria"
  def filter(query, filter_or_filters)

  def filter(q, filters) when is_list(filters), do: Enum.reduce(filters, q, &filter(&2, &1))

  def filter(q, {:join, {rel, jq}}), do: join_to(q, rel, jq)
  def filter(q, {:join, rel}), do: join_to(q, rel)

  def filter(q, {:user, nil}), do: filter(q, deleted: false, hidden: false, published: true)
  def filter(q, {:user, match_admin()}), do: filter(q, deleted: false)
  def filter(q, {:user, %User{id: id}}) do
    q
    |> where([thread: t], not is_nil(t.published_at) or t.creator_id == ^id)
    |> filter(deleted: false, hidden: false)
  end

  
  def filter(q, {:deleted, nil}), do: where(q, [thread: t], is_nil(t.deleted_at))
  def filter(q, {:deleted, :not_nil}), do: where(q, [thread: t], not is_nil(t.deleted_at))
  def filter(q, {:deleted, false}), do: where(q, [thread: t], is_nil(t.deleted_at))
  def filter(q, {:deleted, true}), do: where(q, [thread: t], not is_nil(t.deleted_at))
  def filter(q, {:deleted, {:gte, %DateTime{}=time}}), do: where(q, [thread: t], t.deleted_at >= ^time)
  def filter(q, {:deleted, {:lte, %DateTime{}=time}}), do: where(q, [thread: t], t.deleted_at <= ^time)

  def filter(q, {:hidden, nil}), do: where(q, [thread: t], is_nil(t.hidden_at))
  def filter(q, {:hidden, :not_nil}), do: where(q, [thread: t], not is_nil(t.hidden_at))
  def filter(q, {:hidden, false}), do: where(q, [thread: t], is_nil(t.hidden_at))
  def filter(q, {:hidden, true}), do: where(q, [thread: t], not is_nil(t.hidden_at))
  def filter(q, {:hidden, {:gte, %DateTime{}=time}}), do: where(q, [thread: t], t.hidden_at >= ^time)
  def filter(q, {:hidden, {:lte, %DateTime{}=time}}), do: where(q, [thread: t], t.hidden_at <= ^time)

  def filter(q, {:published, nil}), do: where(q, [thread: t], is_nil(t.published_at))
  def filter(q, {:published, :not_nil}), do: where(q, [thread: t], not is_nil(t.published_at))
  def filter(q, {:published, false}), do: where(q, [thread: t], is_nil(t.published_at))
  def filter(q, {:published, true}), do: where(q, [thread: t], not is_nil(t.published_at))
  def filter(q, {:published, {:gte, %DateTime{}=time}}), do: where(q, [thread: t], t.published_at >= ^time)
  def filter(q, {:published, {:lte, %DateTime{}=time}}), do: where(q, [thread: t], t.published_at <= ^time)

  # fields

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

  def filter(q, {:id, id}) when is_binary(id), do: where(q, [thread: t], t.id == ^id)
  def filter(q, {:id, {:gte, id}}) when is_binary(id), do: where(q, [thread: t], t.id >= ^id)
  def filter(q, {:id, {:lte, id}}) when is_binary(id), do: where(q, [thread: t], t.id <= ^id)
  def filter(q, {:id, ids}) when is_list(ids), do: where(q, [thread: t], t.id in ^ids)

  def filter(q, {:context, id}) when is_binary(id), do: where(q, [thread: t], t.context_id == ^id)
  def filter(q, {:context, ids}) when is_list(ids), do: where(q, [thread: t], t.context_id in ^ids)

  def filter(q, {:creator, id}) when is_binary(id), do: where(q, [thread: t], t.creator_id == ^id)
  def filter(q, {:creator, ids}) when is_list(ids), do: where(q, [thread: t], t.creator_id in ^ids)

  ## ops

  def filter(q, {:order, [desc: :created]}), do: order_by(q, [thread: t], desc: t.id)
  def filter(q, {:order, [desc: :followers]}) do
    order_by q, [thread: t, follower_count: fc],
      desc: coalesce(fc.count, 0),
      desc: t.id
  end

  def filter(q, {:order, [desc: :last_comment]}) do
    order_by q, [thread: t, last_comment: lc], desc: [lc.comment_id, t.id]
  end

  def filter(q, {:group_count, key}) when is_atom(key), do: filter(q, group: key, count: key)

  def filter(q, {:group, key}) when is_atom(key), do: group_by(q, [thread: t], field(t, ^key))

  def filter(q, {:count, key}) when is_atom(key) do
    select q, [thread: t], {field(t, ^key), count(t.id)}
  end

  def filter(q, {:preload, :last_comment}), do: preload(q, [last_comment: lc], last_comment: lc)

  def filter(q, {:limit, limit}), do: limit(q, ^limit)

  def filter(q, {:select, :id}), do: select(q, [thread: t], t.id)

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
