# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Feeds.FeedActivitiesQueries do
  use MoodleNet.Common.Metadata
  alias MoodleNet.Activities
  alias MoodleNet.Feeds.FeedActivity
  alias MoodleNet.Meta.TableService
  import MoodleNet.Common.Query, only: [match_admin: 0]
  import Ecto.Query

  def query(FeedActivity), do: from(f in FeedActivity, as: :feed_activity)

  def query(query, filters), do: filter(query(query), filters)

  defp join_to(q, rel, jq \\ :left)
  defp join_to(q, :activity, jq), do: join(q, jq, [feed_activity: fa], a in assoc(fa, :activity), as: :activity)
  defp join_to(q, :context, jq), do: join(q, jq, [activity: a], c in assoc(a, :context), as: :context)
  defp join_to(q, :feed, jq), do: join(q, jq, [feed_activity: fa], f in assoc(fa, :feed), as: :feed)

  def join_to(q, :context, jq) do
    join q, jq, [activity: a], c in assoc(a, :context), as: :context
  end

  def filter(q, filters) when is_list(filters), do: Enum.reduce(filters, q, &filter(&2, &1))

  def filter(q, {:join, {rel, jq}}), do: join_to(q, rel, jq)
  def filter(q, {:join, rel}), do: join_to(q, rel)

  def filter(q, {:user, match_admin()}), do: Activities.Queries.filter(q, deleted: false)
  def filter(q, {:user, _}), do: Activities.Queries.filter(q, deleted: false, published: true)


  def filter(q, {:id, id}) when is_binary(id), do: where(q, [feed_activity: fa], fa.id == ^id)
  def filter(q, {:id, {:gte, id}}) when is_binary(id), do: where(q, [feed_activity: fa], fa.id >= ^id)
  def filter(q, {:id, {:lte, id}}) when is_binary(id), do: where(q, [feed_activity: fa], fa.id <= ^id)
  def filter(q, {:id, ids}) when is_list(ids), do: where(q, [feed_activity: fa], fa.id in ^ids)

  def filter(q, {:feed, id}) when is_binary(id), do: where(q, [feed_activity: fa], fa.feed_id == ^id)
  def filter(q, {:feed, ids}) when is_list(ids), do: where(q, [feed_activity: fa], fa.feed_id in ^ids)

  def filter(q, {:activity, id}) when is_binary(id), do: where(q, [feed_activity: fa], fa.activity_id == ^id)
  def filter(q, {:activity, ids}) when is_list(ids), do: where(q, [feed_activity: fa], fa.activity_id in ^ids)

  def filter(q, {:table, id}) when is_binary(id), do: where(q, [context: c], c.table_id == ^id)
  def filter(q, {:table, table}) when is_atom(table), do: filter(q, {:table, TableService.lookup_id!(table)})
  def filter(q, {:table, tables}) when is_list(tables) do
    ids = TableService.lookup_ids!(tables)
    where(q, [context: c], c.table_id in ^ids)
  end


  def filter(q, {:limit, n}) when is_integer(n), do: limit(q, ^n)

  def filter(q, {:distinct, field}), do: distinct(q, [feed_activity: fa], field(fa, ^field))

  def filter(q, {:order, [desc: :created]}), do: order_by(q, [feed_activity: fa], [desc: fa.id])


  def filter(q, :unreachable) do
    q
    |> filter(join: :activity, join: :feed)
    |> where([activity: a, feed: f], not is_nil(a.deleted_at) or not is_nil(f.deleted_at))
  end

end
