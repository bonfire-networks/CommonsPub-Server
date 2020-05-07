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

  # the commented out ones are supported in postgres but not yet ecto
  @join_qualifiers [
    :inner, :inner_join, :inner_lateral, :inner_lateral_join,
    :left, :left_join, :left_lateral, :left_lateral_join,
    :right, :right_join, # :right_lateral, :right_lateral_join,
    :cross, :cross_join, # :cross_lateral, :cross_lateral_join,
    :full, :full_join, #:full_lateral, :full_lateral_join
  ]

  defguard is_join_qualifier(x) when x in @join_qualifiers

  def query(Resource), do: from(r in Resource, as: :resource)
  def query(query, filters), do: filter(query(query), filters)

  def join_to(q, spec, join_qualifier \\ :left)
  def join_to(q, specs, jq) when is_list(specs), do: Enum.reduce(specs, q, &join_to(&2, &1, jq))
  def join_to(q, {jq, table}, _) when is_join_qualifier(jq), do: join_to(q, table, jq)

  def join_to(q, :collection, jq), do: join(q, jq, [resource: r], c in assoc(r, :collection), as: :collection)
  def join_to(q, :community, jq), do: join(q, jq, [collection: c], c2 in assoc(c, :community), as: :community)

  def join_to(q, {:community_follow, follower_id}, jq) do
    join q, jq, [community: c], f in Follow, as: :community_follow,
      on: c.id == f.context_id and f.creator_id == ^follower_id
  end

  def join_to(q, {:collection_follow, follower_id}, jq) do
    join q, jq, [collection: c], f in Follow, as: :collection_follow,
      on: c.id == f.context_id and f.creator_id == ^follower_id
  end

  ## filter/2

  def filter(q, filters) when is_list(filters), do: Enum.reduce(filters, q, &filter(&2, &1))

  def filter(q, {:join, join}), do: join_to(q, join)

  def filter(q, {:user, match_admin()}), do: filter(q, deleted: false)

  def filter(q, {:user, %User{id: id}}) do
    filter q,
      join: [ inner: :collection, left: [collection_follow: id],
              inner: :community, left: [community_follow: id] ],
      deleted: false, disabled: false, private: false, # todo private
      follows: :collection, follows: :community # todo not quite right
  end

  def filter(q, {:user, nil}) do
    filter q,
      join: [inner: :collection, inner: :community],
      deleted: false, disabled: false, private: false
  end

  def filter(q, {:follows, :collection}) do
    where q, [collection: c, collection_follow: f],
      not is_nil(c.published_at) or not is_nil(f.id)
  end

  def filter(q, {:follows, :community}) do
    where q, [community: c, community_follow: f],
      not is_nil(c.published_at) or not is_nil(f.id)
  end

  ## status
  
  def filter(q, :deleted), do: where(q, [resource: r], is_nil(r.deleted_at))
  def filter(q, {:deleted, false}), do: where(q, [resource: r], is_nil(r.deleted_at))
  def filter(q, {:deleted, true}), do: where(q, [resource: r], not is_nil(r.deleted_at))

  def filter(q, :disabled), do: where(q, [resource: r], is_nil(r.disabled_at))
  def filter(q, {:disabled, false}), do: where(q, [resource: r], is_nil(r.disabled_at))
  def filter(q, {:disabled, true}), do: where(q, [resource: r], not is_nil(r.disabled_at))

  def filter(q, :private), do: where(q, [resource: r], not is_nil(r.published_at))
  def filter(q, {:private, false}), do: where(q, [resource: r], not is_nil(r.published_at))
  def filter(q, {:private, true}), do: where(q, [resource: r], is_nil(r.published_at))

  # fields

  def filter(q, {:id, id}) when is_binary(id), do: where(q, [resource: r], r.id == ^id)
  def filter(q, {:id, {:gte, id}}) when is_binary(id), do: where(q, [resource: r], r.id >= ^id)
  def filter(q, {:id, {:lte, id}}) when is_binary(id), do: where q, [resource: r], r.id <= ^id
  def filter(q, {:id, ids}) when is_list(ids), do: where q, [resource: r], r.id in ^ids

  def filter(q, {:collection_id, id}) when is_binary(id), do: where(q, [resource: r], r.collection_id == ^id)
  def filter(q, {:collection_id, ids}) when is_list(ids), do: where(q, [resource: r], r.collection_id in ^ids)

  # ops

  def filter(q, {:order, [asc: :created]}), do: order_by(q, [resource: r], [asc: r.id])
  def filter(q, {:order, [desc: :created]}), do: order_by(q, [resource: r], [desc: r.id])

  def filter(q, {:limit, limit}), do: limit(q, ^limit)

  def filter(q, {:group_count, key}) when is_atom(key), do: filter(q, group: key, count: key)

  def filter(q, {:group, key}) when is_atom(key), do: group_by(q, [resource: r], [field(r, ^key)])
  def filter(q, {:count, key}) when is_atom(key), do: select(q, [resource: r], {field(r, ^key), count(r.id)})

  # pagination

  def filter(q, {:page, [desc: [created: %{after: [id], limit: limit}]]}) do
    filter(q, order: [desc: :created], id: {:lte, id}, limit: limit + 2)
  end

  def filter(q, {:page, [desc: [created: %{before: [id], limit: limit}]]}) do
    filter(q, order: [desc: :created], id: {:gte, id}, limit: limit + 2)
  end

  def filter(q, {:page, [desc: [created: %{limit: limit}]]}) do
    filter(q, order: [desc: :created], limit: limit + 1)
  end

  def filter(q, {:page, [asc: [created: %{after: [id], limit: limit}]]}) do
    filter(q, order: [asc: :created], id: {:gte, id}, limit: limit + 2)
  end

  def filter(q, {:page, [asc: [created: %{before: [id], limit: limit}]]}) do
    filter(q, order: [asc: :created], id: {:lte, id}, limit: limit + 2)
  end

  def filter(q, {:page, [asc: [created: %{limit: limit}]]}) do
    filter(q, order: [asc: :created], limit: limit + 1)
  end

end
