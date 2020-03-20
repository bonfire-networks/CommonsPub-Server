# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Resources.Queries do

  import Ecto.Query
  import MoodleNet.Common.Query, only: [match_admin: 0]
  alias MoodleNet.{Collections, Communities}
  alias MoodleNet.Follows.Follow
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Users.User

  def query(Resource) do
    from r in Resource, as: :resource
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

  def join_to(q, spec, join_qualifier \\ :left)

  def join_to(q, specs, jq) when is_list(specs) do
    Enum.reduce(specs, q, &join_to(&2, &1, jq))
  end

  def join_to(q, :collection, jq) do
    join q, jq, [resource: r], c in assoc(r, :collection), as: :collection
  end

  def join_to(q, :community, jq) do
    join q, jq, [collection: c], c2 in assoc(c, :community), as: :community
  end

  def join_to(q, {:community_follow, follower_id}, jq) do
    join q, jq, [community: c], f in Follow, as: :community_follow,
      on: c.id == f.context_id and f.creator_id == ^follower_id
  end

  def join_to(q, {:collection_follow, follower_id}, jq) do
    join q, jq, [collection: c], f in Follow, as: :collection_follow,
      on: c.id == f.context_id and f.creator_id == ^follower_id
  end

  ## by many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  ## by user

  def filter(q, {:user, match_admin()}) do
    filter(q, :deleted)
  end

  def filter(q, {:user, %User{id: id}}) do
    q
    |> join_to([:collection, :community, collection_follow: id, community_follow: id])
    |> filter(~w(deleted disabled user_collection user_community)a)
    |> Collections.Queries.filter(~w(deleted disabled)a)
    |> Communities.Queries.filter(~w(deleted disabled)a)
  end

  def filter(q, {:user, nil}) do
    q
    |> join_to(~w(collection community)a)
    |> filter(~w(deleted disabled private)a)
    |> Collections.Queries.filter(~w(deleted disabled private)a)
    |> Communities.Queries.filter(~w(deleted disabled private)a)
  end

  ## by status
  
  def filter(q, :deleted) do
    where q, [resource: r], is_nil(r.deleted_at)
  end

  def filter(q, :disabled) do
    where q, [resource: r], is_nil(r.disabled_at)
  end

  def filter(q, :private) do
    where q, [resource: r], not is_nil(r.published_at)
  end

  # by field values

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [resource: r], r.id == ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [resource: r], r.id in ^ids
  end

  def filter(q, {:collection_id, id}) when is_binary(id) do
    where q, [resource: r], r.collection_id == ^id
  end

  def filter(q, {:collection_id, ids}) when is_list(ids) do
    where q, [resource: r], r.collection_id in ^ids
  end

  def filter(q, :user_collection) do
    where q, [collection: c, collection_follow: f],
      not is_nil(c.published_at) or not is_nil(f.id)
  end

  def filter(q, :user_community) do
    where q, [community: c, community_follow: f],
      not is_nil(c.published_at) or not is_nil(f.id)
  end

  def filter(q, {:order, :timeline_asc}) do
    order_by q, [resource: r], [asc: r.id]
  end

  def filter(q, {:order, :timeline_desc}) do
    order_by q, [resource: r], [desc: r.id]
  end

  def filter(q, {:group_count, key}) when is_atom(key) do
    filter(q, group: key, count: key)
  end

  def filter(q, {:group, key}) when is_atom(key) do
    group_by q, [resource: r], [field(r, ^key)]
  end

  def filter(q, {:count, key}) when is_atom(key) do
    select q, [resource: r], {field(r, ^key), count(r.id)}
  end

end
