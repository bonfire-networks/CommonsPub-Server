# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Activities.Queries do

  use MoodleNet.Common.Metadata
  alias MoodleNet.Activities.Activity
  alias MoodleNet.Meta.TableService
  import MoodleNet.Common.Query, only: [match_admin: 0]
  alias MoodleNet.Users.User
  alias Ecto.{Query, Queryable}
  import Ecto.Query

  @type status_filter :: :deleted | :private
  @type user_filter :: {:user, User.t | nil}
  @type id_filter :: {:table_id, binary | [binary]}
  @type creator_id_filter :: {:creator_id, binary | [binary]}
  @type table_id_filter :: {:table_id, binary | [binary]}
  @type table_filter :: {:table, TableService.table_id | [TableService.table_id]}
  @type field_filter :: id_filter | creator_id_filter | table_id_filter | table_filter
  @type filter :: status_filter | user_filter | field_filter
  @type filters :: filter | [filter]

  @spec query(Activity) :: Query.t
  def query(Activity) do
    from a in Activity, as: :activity,
      join: c in assoc(a, :context), as: :context,
      preload: [context: c]
  end

  @spec query(Activity, filters) :: Query.t
  def query(q, filters), do: filter(query(q), filters)

  def queries(query, base_filters, data_filters, count_filters) do
    base_q = query(query, base_filters)
    data_q = filter(base_q, data_filters)
    count_q = filter(base_q, count_filters)
    {data_q, count_q}
  end

  def join_to(q, rel, jq \\ :left)

  def join_to(q, :feed_activity, jq) do
    join q, jq, [activity: a], fa in assoc(a, :feed_activities), as: :feed_activity
  end

  ### filter/2

  @doc "Filters the query according to arbitrary filters"
  @spec filter(Queryable.t, filters) :: Query.t
  @will_break_when :privacy # we must figure out how to handle
                            # determining whether the user can see it

  ## by many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
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

  ## by field values

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [activity: a], a.id == ^id
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

  def filter(q, {:distinct, :feed_id}) do
    distinct q, [feed_activity: fa], fa.feed_id
  end

  def filter(q, {:group, :feed_id}) do
    group_by q, [feed_activity: fa], fa.feed_id
  end

  def filter(q, {:group, key}) when is_atom(key) do
    group_by q, [activity: a], field(a, ^key)
  end

  ## ordering

  def filter(q, {:order, :timeline_desc}) do
    order_by q, [activity: a], [desc: a.id]
  end

  ### dynamic filters

  def dyn_filter(:deleted) do
    dynamic([activity: a], is_nil(a.deleted_at))
  end

  def dyn_filter(:private) do
    dynamic([activity: a], not is_nil(a.published_at))
  end

end
