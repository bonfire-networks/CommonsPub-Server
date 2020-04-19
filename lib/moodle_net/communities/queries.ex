# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Communities.Queries do

  alias MoodleNet.Communities.Community
  alias MoodleNet.Follows.{Follow, FollowerCount}
  alias MoodleNet.Users.{LocalUser, User}

  import Ecto.Query

  def query(Community) do
    from c in Community, as: :community,
    join: a in assoc(c, :actor), as: :actor
  end

  def query(query, filters), do: filter(query(query), filters)

  def queries(query, _page_opts, base_filters, data_filters, count_filters) do
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

  ## special

  def filter(q, :default) do
    filter q, [:deleted, preload: :actor]
  end

  ## by join

  def filter(q, {:join, {join, qual}}), do: join_to(q, join, qual)
  def filter(q, {:join, join}), do: join_to(q, join)

  ## by order

  def filter(q, {:order, :list}), do: list(q)

  def filter(q, {:order, [asc: :created]}) do
    order_by q, [community: c], asc: c.id
  end

  def filter(q, {:order, [desc: :created]}) do
    order_by q, [community: c], desc: c.id
  end

  def filter(q, {:order, [asc: :followers]}) do
    order_by q, [community: c, follower_count: fc],
      asc: coalesce(fc.count, 0),
      desc: c.id # most recent
  end

  def filter(q, {:order, [desc: :followers]}) do
    order_by q, [community: c, follower_count: fc],
      desc: coalesce(fc.count, 0),
      desc: c.id
  end

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
    where q, [community: c], is_nil(c.id) or not is_nil(c.published_at)
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

  def filter(q, {:cursor, [followers: {:gte, [count, id]}]})
  when is_integer(count) and is_binary(id) do
    where q,[community: c, follower_count: fc],
      (fc.count == ^count and c.id >= ^id) or fc.count > ^count
  end

  def filter(q, {:cursor, [followers: {:lte, [count, id]}]})
  when is_integer(count) and is_binary(id) do
    where q,[community: c, follower_count: fc],
      (fc.count == ^count and c.id <= ^id) or fc.count < ^count
  end

  ## by preload

  def filter(q, {:preload, :actor}) do
    preload q, [actor: a], [actor: a]
  end

  def filter(q, {:page, [desc: [followers: page_opts]]}) do
    q
    |> filter(join: :follower_count, order: [desc: :followers])
    |> page(page_opts, [desc: :followers])
    |> select(
      [community: c, actor: a, follower_count: fc],
      %{c | follower_count: coalesce(fc.count, 0), actor: a}
    )
  end

  defp page(q, %{after: cursor, limit: limit}, [desc: :followers]) do
    filter q, cursor: [followers: {:lte, cursor}], limit: limit + 2
  end

  defp page(q, %{before: cursor, limit: limit}, [desc: :followers]) do
    filter q, cursor: [followers: {:gte, cursor}], limit: limit + 2
  end

  defp page(q, %{limit: limit}, [desc: :followers]), do: filter(q, limit: limit + 1)

  def filter(q, {:limit, limit}) do
    limit(q, ^limit)
  end

  @doc """
  Orders by:
  * Most followers
  * Most recently updated (TODO recent activity)
  * Community ULID (Most recently created + jitter)
  """
  def list(q) do
    order_by q, [community: c, follower_count: f],
      desc: coalesce(f.count, 0),
      desc: c.updated_at,
      desc: c.id
  end

  def group_count(q, key) do
    q
    |> group_by([community: c], field(c, ^key))
    |> select([community: c], {field(c, ^key), count(c.id)})
  end



end
