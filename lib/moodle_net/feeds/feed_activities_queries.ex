# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Feeds.FeedActivitiesQueries do
  use MoodleNet.Common.Metadata
  alias MoodleNet.Activities
  alias MoodleNet.Feeds.FeedActivity
  alias MoodleNet.Meta.TableService
  import MoodleNet.Common.Query, only: [match_admin: 0]
  import Ecto.Query

  # we will probably never want to not prefetch these
  def query(FeedActivity) do
    from f in FeedActivity, as: :feed_activity,
      join: a in assoc(f, :activity), as: :activity,
      join: c in assoc(a, :context), as: :context,
      preload: [activity: {a, context: c}]
  end

  def query(query, filters), do: filter(query(query), filters)

  def queries(query, base_filters, data_filters, count_filters) do
    base_q = query(query, base_filters)
    data_q = filter(base_q, data_filters)
    count_q = filter(base_q, count_filters)
    {data_q, count_q}
  end

  ### filter/2

  @will_break_when :privacy # determine when a user can see items

  ## by many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  ## by user

  def filter(q, {:user, match_admin()}), do: Activities.Queries.filter(q, :deleted)

  # Guest or ordinary user are currently not treated differently
  def filter(q, {:user, _}), do: Activities.Queries.filter(q, ~w(deleted private))

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

  ## by limit

  def filter(q, {:limit, n}) when is_integer(n), do: limit(q, ^n)

  ## by field values

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [feed_activity: fa], fa.id == ^id
  end

  def filter(q, {:id, {:gte, id}}) when is_binary(id) do
    where q, [feed_activity: fa], fa.id >= ^id
  end

  def filter(q, {:id, {:lte, id}}) when is_binary(id) do
    where q, [feed_activity: fa], fa.id <= ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [feed_activity: fa], fa.id in ^ids
  end

  def filter(q, {:feed_id, id}) when is_binary(id) do
    where q, [feed_activity: fa], fa.feed_id == ^id
  end

  def filter(q, {:feed_id, ids}) when is_list(ids) do
    where q, [feed_activity: fa], fa.feed_id in ^ids
  end

  def filter(q, {:activity_id, id}) when is_binary(id) do
    where q, [feed_activity: fa], fa.activity_id == ^id
  end

  def filter(q, {:activity_id, ids}) when is_list(ids) do
    where q, [feed_activity: fa], fa.activity_id in ^ids
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

  ## by order

  def filter(q, {:order, :timeline_desc}) do
    order_by q, [feed_activity: fa], [desc: fa.id]
  end

  def filter(q, {:distinct, field}) do
    distinct q, [feed_activity: fa], fa.activity_id
  end
end
