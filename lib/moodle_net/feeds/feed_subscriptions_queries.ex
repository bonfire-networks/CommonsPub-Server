# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Feeds.FeedSubscriptionsQueries do
  alias MoodleNet.Feeds.FeedSubscription
  alias MoodleNet.Meta.TableService
  import Ecto.Query

  def query(FeedSubscription), do: from(fs in FeedSubscription, as: :subscription)

  def query(query, filters), do: filter(query(query), filters)

  @doc "Filter the query according to arbitrary criteria"
  def filter(q, filter_or_filters)

  def filter(q, filters) when is_list(filters), do: Enum.reduce(filters, q, &filter(&2, &1))

  def filter(q, {:deleted, nil}), do: where(q, [subscription: s], is_nil(s.deleted_at))
  def filter(q, {:deleted, :not_nil}), do: where(q, [subscription: s], not is_nil(s.deleted_at))
  def filter(q, {:deleted, false}), do: where(q, [subscription: s], is_nil(s.deleted_at))
  def filter(q, {:deleted, true}), do: where(q, [subscription: s], not is_nil(s.deleted_at))
  def filter(q, {:deleted, {:gte, %DateTime{}=time}}), do: where(q, [subscription: s], s.deleted_at >= ^time)
  def filter(q, {:deleted, {:lte, %DateTime{}=time}}), do: where(q, [subscription: s], s.deleted_at <= ^time)

  def filter(q, {:disabled, nil}), do: where(q, [subscription: s], is_nil(s.disabled_at))
  def filter(q, {:disabled, :not_nil}), do: where(q, [subscription: s], not is_nil(s.disabled_at))
  def filter(q, {:disabled, false}), do: where(q, [subscription: s], is_nil(s.disabled_at))
  def filter(q, {:disabled, true}), do: where(q, [subscription: s], not is_nil(s.disabled_at))
  def filter(q, {:disabled, {:gte, %DateTime{}=time}}), do: where(q, [subscription: s], s.disabled_at >= ^time)
  def filter(q, {:disabled, {:lte, %DateTime{}=time}}), do: where(q, [subscription: s], s.disabled_at <= ^time)

  def filter(q, {:activated, nil}), do: where(q, [subscription: s], is_nil(s.activated_at))
  def filter(q, {:activated, :not_nil}), do: where(q, [subscription: s], not is_nil(s.activated_at))
  def filter(q, {:activated, false}), do: where(q, [subscription: s], is_nil(s.activated_at))
  def filter(q, {:activated, true}), do: where(q, [subscription: s], not is_nil(s.activated_at))

  def filter(q, {:id, id}) when is_binary(id), do: where(q, [subscription: s], s.id == ^id)
  def filter(q, {:id, ids}) when is_list(ids), do: where(q, [subscription: s], s.id in ^ids)

  def filter(q, {:feed, id}) when is_binary(id), do: where(q, [subscription: s], s.feed_id == ^id)
  def filter(q, {:feed, ids}) when is_list(ids), do: where(q, [subscription: s], s.feed_id in ^ids)

  def filter(q, {:subscriber, id}) when is_binary(id), do: where(q, [subscription: s], s.subscriber_id == ^id)
  def filter(q, {:subscriber, ids}) when is_list(ids), do: where(q, [subscription: s], s.subscriber_id in ^ids)

  def filter(q, {:table, id}) when is_binary(id), do: where(q, [subscriber: s], s.table_id == ^id)
  def filter(q, {:table, table}) when is_atom(table), do: filter(q, {:table, TableService.lookup_id!(table)})
  def filter(q, {:table, tables}) when is_list(tables) do
    ids = TableService.lookup_ids!(tables)
    where(q, [subscriber: s], s.table_id in ^ids)
  end


  def filter(q, :unreachable) do
    q
    |> filter(join: :activity, join: :feed)
    |> where([activity: a, feed: f], not is_nil(a.deleted_at) or not is_nil(f.deleted_at))
  end

end
