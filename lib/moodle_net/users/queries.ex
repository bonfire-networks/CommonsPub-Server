# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.Queries do

  import Ecto.Query
  import MoodleNet.Common.Query, only: [match_admin: 0]
  alias MoodleNet.Actors
  alias MoodleNet.Follows.{Follow, FollowerCount}
  alias MoodleNet.Users.User

  def query(User) do
    from u in User, as: :user,
      join: a in assoc(u, :actor), as: :actor,
      preload: [actor: a]
  end

  def query(query, filters), do: filter(query(query), filters)

  def join_to(q, spec, join_qualifier \\ :left)

  def join_to(q, :local_user, jq) do
    join q, jq, [user: u], assoc(u, :local_user), as: :local_user
  end

  def join_to(q, {:follow, follower_id}, jq) do
    join q, jq, [user: u], f in Follow, as: :follow,
      on: u.id == f.context_id and f.creator_id == ^follower_id
  end

  def join_to(q, :follower_count, jq) do
    join q, jq, [user: u],
      fc in FollowerCount, on: u.id == fc.context_id,
      as: :follower_count
  end

  @doc "Filter the query according to arbitrary criteria"
  def filter(q, filter_or_filters)

  ## by many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  ## by special

  def filter(q, :default) do
    q
    |> filter([:deleted, join: :local_user, preload: :local_user])
  end

  ## by join

  def filter(q, {:join, {join, qual}}), do: join_to(q, join, qual)
  def filter(q, {:join, join}), do: join_to(q, join)

  ## by users
  
  def filter(q, {:user, match_admin()}), do: q

  def filter(q, {:user, %User{id: id}}) do
    join_to(q, {:follow, id})
    |> where([follow: f, user: u], not is_nil(u.published_at) or not is_nil(f.id))
    |> filter(:disabled)
  end
  
  def filter(q, {:user, nil}) do # guest
    filter q, ~w(disabled private)a
  end

  ## by status
  
  def filter(q, :deleted) do
    where q, [user: u], is_nil(u.deleted_at)
  end

  def filter(q, :disabled) do
    where q, [user: u], is_nil(u.disabled_at)
  end

  def filter(q, :private) do
    where q, [user: u], not is_nil(u.published_at)
  end

  def filter(q, :local), do: Actors.Queries.filter(q, :local)

  def filter(q, :remote), do: Actors.Queries.filter(q, :remote)

  # by field values

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [user: u], u.id == ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [user: u], u.id in ^ids
  end

  def filter(q, {:local_user_id, id}) when is_binary(id) do
    where q, [local_user: l], l.id == ^id
  end

  def filter(q, {:local_user_id, ids}) when is_list(ids) do
    where q, [local_user: l], l.id in ^ids
  end

  def filter(q, {:username, username}) do
    Actors.Queries.filter(q, {:username, username})
  end

  def filter(q, {:email, email}) when is_binary(email) do
    where q, [local_user: l], l.email == ^email
  end

  def filter(q, {:email, emails}) when is_list(emails) do
    where q, [local_user: l], l.email in ^emails
  end

  ## order

  def filter(q, {:order, :timeline_desc}) do
    order_by q, [user: u], [desc: u.id]
  end

  ## preload

  def filter(q, {:preload, :local_user}) do
    preload(q, [local_user: u], [local_user: u])
  end

end

