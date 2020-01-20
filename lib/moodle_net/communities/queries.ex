# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Communities.Queries do

  alias MoodleNet.Communities.Community
  alias MoodleNet.Follows.{Follow, FollowerCount}
  alias MoodleNet.Users.{LocalUser, User}

  import Ecto.Query

  def query(Community) do
    from c in Community, as: :community,
      join: a in assoc(c, :actor), as: :actor,
      preload: [actor: a]
  end

  def query(query, filters), do: filter(query(query), filters)

  def queries(query, base_filters, data_filters, count_filters) do
    base_q = query(query, base_filters)
    data_q = filter(base_q, data_filters)
    count_q = filter(base_q, count_filters)
    {data_q, count_q}
  end

  def join_to(q, spec, join_qualifier \\ :left)

  def join_to(q, {:follow, follower_id}, jq) do
    join q, jq, [community: c], f in Follow, as: :follow,
      on: c.id == f.context_id and f.creator_id == ^follower_id
  end

  def join_to(q, :follower_count, jq) do
    join q, jq, [community: c],
      fc in FollowerCount, on: c.id == fc.context_id,
      as: :follower_count
  end

  @doc "Filter the query according to arbitrary criteria"
  def filter(q, filter_or_filters)

  ## by many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  ## by join

  def filter(q, {:join, {join, qual}}), do: join_to(q, join, qual)
  def filter(q, {:join, join}), do: join_to(q, join)

  ## by order

  def filter(q, {:order, :list}), do: list(q)

  ## by users
  
  def filter(q, {:user, %User{local_user: %LocalUser{is_instance_admin: true}}}) do
    filter(q, :deleted)
  end

  def filter(q, {:user, %User{id: id}}) do
    join_to(q, {:follow, id})
    |> where([follow: f, community: c], not is_nil(c.published_at) or not is_nil(f.id))
  end

  def filter(q, {:user, nil}) do # guest
    filter q, ~w(deleted disabled private)a
  end

  ## by status
  
  def filter(q, :deleted) do
    where q, [community: c], is_nil(c.deleted_at)
  end

  def filter(q, :disabled) do
    where q, [community: c], is_nil(c.disabled_at)
  end

  def filter(q, :private) do
    where q, [community: c], not is_nil(c.published_at)
  end

  # by field values

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [community: c], c.id == ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [community: c], c.id in ^ids
  end

  def filter(q, {:username, username}) when is_binary(username) do
    where q, [actor: a], a.preferred_username == ^username
  end

  def filter(q, {:username, usernames}) when is_list(usernames) do
    where q, [actor: a], a.preferred_username in ^usernames
  end

  @doc """
  Orders by:
  * Most followers
  * Most recently updated (TODO recent activity)
  * Community ULID (Most recently created + jitter)
  """
  def list(q, filters \\ []) do
    order_by q, [community: c, follower_count: f],
      desc: coalesce(f.count, 0),
      desc: c.updated_at,
      desc: c.id
  end

  def group_count(q, key, filters \\ []) do
    q
    |> group_by([community: c], field(c, ^key))
    |> select([community: c], {field(c, ^key), count(c.id)})
  end

end
