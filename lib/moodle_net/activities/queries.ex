# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Activities.Queries do
  @enforce_keys ~w(query)a
  defstruct @enforce_keys

  use MoodleNet.Common.Metadata
  alias MoodleNet.Activities.Activity
  alias MoodleNet.Meta.TableService
  import MoodleNet.Common.Query, only: [match_admin: 0]
  import Ecto.Query

  @default_limit 25
  def query(Activity) do
    from a in Activity, as: :activity,
      join: c in assoc(a, :context), as: :context,
      preload: [context: c]
  end

  def query(q, filters), do: filter(query(q), filters)

  def join_to(q, rel, jq \\ :left)

  def join_to(q, :feed_activity, jq) do
    join q, jq, [activity: a], fa in assoc(a, :feed_activities), as: :feed_activity
  end

  ### filter/2

  @doc "Filters the query according to arbitrary filters"
  @will_break_when :privacy # we must figure out how to handle
                            # determining whether the user can see it

  ## by many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  ## by preset

  def filter(q, {:feed, id}) do
    filter q,
      join: :feed_activity,
      feed_id: id,
      distinct: [desc: :id], # this does the actual ordering *sigh*
      order: :timeline_desc  # this is here because ecto knows better than me oslt
  end

  ## by join

  def filter(q, {:join,{rel, jq}}), do: join_to(q, rel, jq)

  def filter(q, {:join,rel}), do: join_to(q, rel)

  ## by user

  def filter(q, {:user, match_admin()}) do
    filter(q, :deleted)
  end

  def filter(q, {:user, _}), do: filter(q, ~w(deleted private)a)

  ## by status
  
  def filter(q, :deleted) do
    where q, [activity: a], is_nil(a.deleted_at)
  end

  def filter(q, :private) do
    where q, [activity: a], not is_nil(a.published_at)
  end

  ## by limit

  def filter(q, {:limit, n}) when is_integer(n), do: limit(q, ^n)

  ## by field values

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [activity: a], a.id == ^id
  end

  def filter(q, {:id, {:gte, id}}) when is_binary(id) do
    where q, [activity: a], a.id >= ^id
  end

  def filter(q, {:id, {:lte, id}}) when is_binary(id) do
    where q, [activity: a], a.id <= ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [activity: a], a.id in ^ids
  end

  def filter(q, {:creator_id, id}) when is_binary(id) do
    where q, [activity: a], a.creator_id == ^id
  end

  def filter(q, {:creator_id, ids}) when is_list(ids) do
    where q, [activity: a], a.creator_id in ^ids
  end

  def filter(q, {:context_id, id}) when is_binary(id) do
    where q, [activity: a], a.context_id == ^id
  end

  def filter(q, {:context_id, ids}) when is_list(ids) do
    where q, [activity: a], a.context_id in ^ids
  end

  def filter(q, {:table_id, id}) when is_binary(id) do
    where q, [context: c], c.table_id == ^id
  end

  def filter(q, {:table_id, ids}) when is_list(ids) do
    where q, [context: c], c.table_id in ^ids
  end

  def filter(q, {:table, table}) when is_atom(table) do
    id = TableService.lookup_id!(table)
    where q, [context: c], c.table_id == ^id
  end

  def filter(q, {:table, tables}) when is_list(tables) do
    ids = Enum.map(tables, &TableService.lookup_id!/1)
    where q, [context: c], c.table_id in ^ids
  end

  def filter(q, {:feed_id, id}) when is_binary(id) do
    where q, [feed_activity: fa], fa.feed_id == ^id
  end

  def filter(q, {:feed_id, ids}) when is_list(ids) do
    where q, [feed_activity: fa], fa.feed_id in ^ids
  end

  ## grouping

  def filter(q, {:distinct, [desc: key]}) when is_atom(key) do
    distinct q, [activity: a], [desc: field(a, ^key)]
  end

  def filter(q, {:distinct, [asc: key]}) when is_atom(key) do
    distinct q, [activity: a], [asc: field(a, ^key)]
  end

  def filter(q, {:distinct, key}) when is_atom(key) do
    distinct q, [activity: a], field(a, ^key)
  end

  def filter(q, {:group, :feed_id}) do
    group_by q, [feed_activity: fa], fa.feed_id
  end

  def filter(q, {:group, key}) when is_atom(key) do
    group_by q, [activity: a], field(a, ^key)
  end

  ## ordering

  def filter(q, {:order, :timeline_asc}) do
    order_by q, [activity: a], [asc: a.id]
  end

  def filter(q, {:order, :timeline_desc}) do
    order_by q, [activity: a], [desc: a.id]
  end

  ## by pagination

  @min_limit 1
  @max_limit 100
  @default_limit 25
  def filter(q, {:paginate, {:timeline_desc, %{after: a}=opts}}) do
    lim = 2 + get_limit(opts)
    filter(q, order: :timeline_desc, limit: lim, id: {:lte, lim})
  end

  def filter(q, {:paginate, {:timeline_desc, %{before: a}=opts}}) do
    lim = 2 + get_limit(opts)
    filter(q, order: :timeline_desc, limit: lim, id: {:gte, lim})
  end 

  def filter(q, {:paginate, {:timeline_desc, %{}=opts}}) do
    lim = 1 + get_limit(opts)
    filter(q, order: :timeline_desc, limit: lim)
  end

  defp get_limit(%{limit: n}) when is_integer(n) do
    cond do
      n < @min_limit -> @min_limit
      n > @max_limit -> @max_limit
      true -> n
    end
  end
  defp get_limit(%{}), do: @default_limit


  ### dynamic filters

  def dyn_filter(:deleted) do
    dynamic([activity: a], is_nil(a.deleted_at))
  end

  def dyn_filter(:private) do
    dynamic([activity: a], not is_nil(a.published_at))
  end

end
