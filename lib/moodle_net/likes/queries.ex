# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Likes.Queries do
  alias MoodleNet.Likes.Like
  alias MoodleNet.Users.{LocalUser, User}
  import Ecto.Query

  def query(Like) do
    from l in Like, as: :like
  end

  def query(query, filters), do: filter(query(query), filters)

  def queries(query, _page_opts, base_filters, data_filters, count_filters) do
    base_q = query(query, base_filters)
    data_q = filter(base_q, data_filters)
    count_q = filter(base_q, count_filters)
    {data_q, count_q}
  end

  @doc "Filter the query according to arbitrary criteria"
  def filter(q, filter_or_filters)

  ## by many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  ## by users
  
  def filter(q, {:user, %User{local_user: %LocalUser{is_instance_admin: true}}}) do
    filter(q, :deleted)
  end

  def filter(q, {:user, %User{id: id}}) do
    where q, [like: l], not is_nil(l.published_at) or l.creator_id == ^id
  end

  def filter(q, {:user, nil}) do # guest
    filter q, ~w(deleted private)a
  end

  ## by status
  
  def filter(q, :deleted) do
    where q, [like: l], is_nil(l.deleted_at)
  end

  def filter(q, :private) do
    where q, [like: l], not is_nil(l.published_at)
  end

  # by field values

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [like: l], l.id == ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [like: l], l.id in ^ids
  end

  def filter(q, {:context_id, id}) when is_binary(id) do
    where q, [like: l], l.context_id == ^id
  end

  def filter(q, {:context_id, ids}) when is_list(ids) do
    where q, [like: l], l.context_id in ^ids
  end

  def filter(q, {:creator_id, id}) when is_binary(id) do
    where q, [like: l], l.creator_id == ^id
  end

  def filter(q, {:creator_id, ids}) when is_list(ids) do
    where q, [like: l], l.creator_id in ^ids
  end

  def filter(q, {:order, :timeline_desc}) do
    order_by q, [like: l], [desc: l.id]
  end

  def filter(q, {:group_count, key}) when is_atom(key) do
    filter(q, group: key, count: key)
  end

  def filter(q, {:group, key}) when is_atom(key) do
    group_by q, [like: l], field(l, ^key)
  end

  def filter(q, {:count, key}) when is_atom(key) do
    select q, [like: l], {field(l, ^key), count(l.id)}
  end

end
