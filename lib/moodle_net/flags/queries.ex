# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Flags.Queries do
  alias MoodleNet.Flags.Flag
  alias MoodleNet.Users.{LocalUser, User}
  import Ecto.Query

  def query(Flag) do
    from f in Flag, as: :flag
  end
  def query(query, filters), do: filter(query(query), filters)

  def queries(query, base_filters, data_filters, count_filters) do
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
    where q, [flag: f], f.creator_id == ^id
  end

  ## by status
  
  def filter(q, :deleted) do
    where q, [flag: f], is_nil(f.deleted_at)
  end

  def filter(q, :private) do
    where q, [flag: f], not is_nil(f.published_at)
  end

  # by field values

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [flag: f], f.id == ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [flag: f], f.id in ^ids
  end

  def filter(q, {:context_id, id}) when is_binary(id) do
    where q, [flag: f], f.context_id == ^id
  end

  def filter(q, {:context_id, ids}) when is_list(ids) do
    where q, [flag: f], f.context_id in ^ids
  end

  def filter(q, {:creator_id, id}) when is_binary(id) do
    where q, [flag: f], f.creator_id == ^id
  end

  def filter(q, {:creator_id, ids}) when is_list(ids) do
    where q, [flag: f], f.creator_id in ^ids
  end

  def filter(q, {:community_id, nil}) do
    where q, [flag: f], is_nil(f.community_id)
  end

  def filter(q, {:community_id, id}) when is_binary(id) do
    where q, [flag: f], f.community_id == ^id
  end

  def filter(q, {:community_id, ids}) when is_list(ids) do
    where q, [flag: f], f.community_id in ^ids
  end

  def filter(q, {:order, :timeline_desc}) do
    order_by q, [flag: f], [desc: f.id]
  end

  def filter(q, {:group_count, key}) when is_atom(key) do
    filter(q, group: key, count: key)
  end

  def filter(q, {:group, key}) when is_atom(key) do
    group_by q, [flag: f], field(f, ^key)
  end

  def filter(q, {:count, key}) when is_atom(key) do
    select q, [flag: f], {field(f, ^key), count(f.id)}
  end

end
