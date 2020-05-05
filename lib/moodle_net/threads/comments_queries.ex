# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Threads.CommentsQueries do

  alias MoodleNet.Threads.Comment
  alias MoodleNet.Users.User
  import MoodleNet.Common.Query, only: [match_admin: 0]

  import Ecto.Query
  
  def query(Comment) do
    from c in Comment, as: :comment
  end

  def query(query, filters), do: filter(query(query), filters)

  def join_to(q, rel, jq \\ :left)
  def join_to(q, :thread, jq) do
    join q, jq, [comment: c], t in assoc(c, :thread), as: :thread
  end

  @doc "Filter the query according to arbitrary criteria"
  def filter(q, filter_or_filters)

  ## by many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  ## by users
  
  def filter(q, {:user, match_admin()}) do
    filter(q, :deleted)
  end

  def filter(q, {:user, %User{id: id}}) do
    where q, [comment: c], not is_nil(c.published_at) or c.creator_id == ^id
  end

  def filter(q, {:user, nil}) do # guest
    filter q, ~w(deleted private)a
  end

  ## by status
  
  def filter(q, :deleted) do
    where q, [comment: c], is_nil(c.deleted_at)
  end

  def filter(q, :hidden) do
    where q, [comment: c], is_nil(c.hidden_at)
  end

  def filter(q, :private) do
    where q, [comment: c], not is_nil(c.published_at)
  end

  # by field values

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [comment: c], c.id == ^id
  end

  def filter(q, {:id, {:gte, id}}) when is_binary(id) do
    where q, [comment: c], c.id >= ^id
  end

  def filter(q, {:id, {:lte, id}}) when is_binary(id) do
    where q, [comment: c], c.id <= ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [comment: c], c.id in ^ids
  end

  def filter(q, {:thread_id, id}) when is_binary(id) do
    where q, [comment: c], c.thread_id == ^id
  end

  def filter(q, {:thread_id, ids}) when is_list(ids) do
    where q, [comment: c], c.thread_id in ^ids
  end

  def filter(q, {:in_reply_to_id, id}) when is_binary(id) do
    where q, [comment: c], c.in_reply_to_id == ^id
  end

  def filter(q, {:in_reply_to_id, ids}) when is_list(ids) do
    where q, [comment: c], c.in_reply_to_id in ^ids
  end

  def filter(q, {:creator_id, id}) when is_binary(id) do
    where q, [comment: c], c.creator_id == ^id
  end

  def filter(q, {:creator_id, ids}) when is_list(ids) do
    where q, [comment: c], c.creator_id in ^ids
  end

  def filter(q, {:order, [asc: :created]}) do
    order_by(q, [comment: c], [asc: c.id])
  end

  def filter(q, {:order, [desc: :created]}) do
    order_by(q, [comment: c], [desc: c.id])
  end
  
  def filter(q, {:group_count, key}) when is_atom(key) do
    filter(q, group: key, count: key)
  end

  def filter(q, {:group, key}) when is_atom(key) do
    group_by(q, [comment: c], field(c, ^key))
  end

  def filter(q, {:count, key}) when is_atom(key) do
    select(q, [comment: c], {field(c, ^key), count(c.id)})
  end

  def filter(q, {:limit, limit}) when is_integer(limit) and limit > 0 do
    limit(q, ^limit)
  end

  def filter(q, {:page, [desc: [created: page_opts]]}) do
    q
    |> filter(order: [desc: :created])
    |> page(page_opts, [desc: :created])
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
