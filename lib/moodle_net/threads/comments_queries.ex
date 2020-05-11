# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Threads.CommentsQueries do

  alias MoodleNet.Threads.Comment
  alias MoodleNet.Users.User
  import MoodleNet.Common.Query, only: [match_admin: 0]

  import Ecto.Query
  
  def query(Comment), do: from(c in Comment, as: :comment)

  def query(query, filters), do: filter(query(query), filters)

  defp join_to(q, rel, jq \\ :left)
  defp join_to(q, :thread, jq), do: join(q, jq, [comment: c], t in assoc(c, :thread), as: :thread)

  @doc "Filter the query according to arbitrary criteria"
  def filter(q, filter_or_filters)

  def filter(q, filters) when is_list(filters), do: Enum.reduce(filters, q, &filter(&2, &1))

  def filter(q, {:user, nil}), do: filter(q, deleted: false, published: true)
  def filter(q, {:user, match_admin()}), do: filter(q, deleted: false)
  def filter(q, {:user, %User{id: id}}) do
    where q, [comment: c], not is_nil(c.published_at) or c.creator_id == ^id
  end

  def filter(q, {:deleted, nil}), do: where(q, [comment: c], is_nil(c.deleted_at))
  def filter(q, {:deleted, :not_nil}), do: where(q, [comment: c], not is_nil(c.deleted_at))
  def filter(q, {:deleted, false}), do: where(q, [comment: c], is_nil(c.deleted_at))
  def filter(q, {:deleted, true}), do: where(q, [comment: c], not is_nil(c.deleted_at))
  def filter(q, {:deleted, {:gte, %DateTime{}=time}}), do: where(q, [comment: c], c.deleted_at >= ^time)
  def filter(q, {:deleted, {:lte, %DateTime{}=time}}), do: where(q, [comment: c], c.deleted_at <= ^time)

  def filter(q, {:hidden, nil}), do: where(q, [comment: c], is_nil(c.hidden_at))
  def filter(q, {:hidden, :not_nil}), do: where(q, [comment: c], not is_nil(c.hidden_at))
  def filter(q, {:hidden, false}), do: where(q, [comment: c], is_nil(c.hidden_at))
  def filter(q, {:hidden, true}), do: where(q, [comment: c], not is_nil(c.hidden_at))
  def filter(q, {:hidden, {:gte, %DateTime{}=time}}), do: where(q, [comment: c], c.hidden_at >= ^time)
  def filter(q, {:hidden, {:lte, %DateTime{}=time}}), do: where(q, [comment: c], c.hidden_at <= ^time)

  def filter(q, {:published, nil}), do: where(q, [comment: c], is_nil(c.published_at))
  def filter(q, {:published, :not_nil}), do: where(q, [comment: c], not is_nil(c.published_at))
  def filter(q, {:published, false}), do: where(q, [comment: c], is_nil(c.published_at))
  def filter(q, {:published, true}), do: where(q, [comment: c], not is_nil(c.published_at))
  def filter(q, {:published, {:gte, %DateTime{}=time}}), do: where(q, [comment: c], c.published_at >= ^time)
  def filter(q, {:published, {:lte, %DateTime{}=time}}), do: where(q, [comment: c], c.published_at <= ^time)


  def filter(q, {:id, id}) when is_binary(id), do: where(q, [comment: c], c.id == ^id)
  def filter(q, {:id, {:gte, id}}) when is_binary(id), do: where(q, [comment: c], c.id >= ^id)
  def filter(q, {:id, {:lte, id}}) when is_binary(id), do: where(q, [comment: c], c.id <= ^id)
  def filter(q, {:id, ids}) when is_list(ids), do: where(q, [comment: c], c.id in ^ids)

  def filter(q, {:thread, id}) when is_binary(id), do: where(q, [comment: c], c.thread_id == ^id)
  def filter(q, {:thread, ids}) when is_list(ids), do: where(q, [comment: c], c.thread_id in ^ids)

  def filter(q, {:in_reply_to, id}) when is_binary(id), do: where(q, [comment: c], c.in_reply_to_id == ^id)
  def filter(q, {:in_reply_to, ids}) when is_list(ids), do: where(q, [comment: c], c.in_reply_to_id in ^ids)

  def filter(q, {:creator, id}) when is_binary(id), do: where(q, [comment: c], c.creator_id == ^id)
  def filter(q, {:creator, ids}) when is_list(ids), do: where(q, [comment: c], c.creator_id in ^ids)


  def filter(q, {:order, [asc: :created]}), do: order_by(q, [comment: c], [asc: c.id])
  def filter(q, {:order, [desc: :created]}), do: order_by(q, [comment: c], [desc: c.id])
  
  def filter(q, {:group_count, key}) when is_atom(key), do: filter(q, group: key, count: key)

  def filter(q, {:group, key}) when is_atom(key), do: group_by(q, [comment: c], field(c, ^key))

  def filter(q, {:count, key}) when is_atom(key), do: select(q, [comment: c], {field(c, ^key), count(c.id)})

  def filter(q, {:limit, limit}) when is_integer(limit) and limit > 0, do: limit(q, ^limit)

  def filter(q, {:page, [{order, [{field, page_opts}]}]}) do
    q
    |> filter(order: [{order, field}])
    |> page(page_opts, [{order, field}])
  end

  defp page(q, %{after: cursor, limit: limit}, [asc: :created]) do
    filter q, id: {:gte, cursor}, limit: limit + 2
  end

  defp page(q, %{after: cursor, limit: limit}, [desc: :created]) do
    filter q, id: {:lte, cursor}, limit: limit + 2
  end

  defp page(q, %{before: cursor, limit: limit}, [asc: :created]) do
    filter q, id: {:lte, cursor}, limit: limit + 2
  end

  defp page(q, %{before: cursor, limit: limit}, [desc: :created]) do
    filter q, id: {:gte, cursor}, limit: limit + 2
  end

  defp page(q, %{limit: limit}, _), do: filter(q, limit: limit + 1)

end
