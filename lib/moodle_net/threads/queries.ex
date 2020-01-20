# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Threads.Queries do

  alias MoodleNet.{Repo}
  alias MoodleNet.Threads.{Comment, FollowerCount, LastComment, Thread}
  alias MoodleNet.Users.{LocalUser, User}
  import Ecto.Query

  def query(Thread) do
    from t in Thread, as: :thread
  end

  def query(query, filters) do
    filter(query(query), filters)
  end
  
  def queries(query, base_filters, data_filters, count_filters) do
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

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [thread: t], t.id == ^id
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

  def filter(q, {:order, :last_comment_desc}) do
    order_by q, [last_comment: lc], desc: lc.comment_id
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

end
