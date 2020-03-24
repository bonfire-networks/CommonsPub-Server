# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Feeds.FeedSubscriptionsQueries do
  alias MoodleNet.Feeds.FeedSubscription
  import Ecto.Query

  def query(FeedSubscription) do
    from fs in FeedSubscription, as: :feed_subscription
  end

  def query(query, filters), do: filter(query(query), filters)

  @doc "Filter the query according to arbitrary criteria"
  def filter(q, filter_or_filters)

  ## by many

  def filter(q, filters) when is_list(filters) do
    Enum.reduce(filters, q, &filter(&2, &1))
  end

  ## by status
  
  def filter(q, :deleted) do
    where q, [feed_subscription: fs], is_nil(fs.deleted_at)
  end

  def filter(q, :disabled) do
    where q, [feed_subscription: fs], is_nil(fs.disabled_at)
  end

  def filter(q, :inactive) do
    where q, [feed_subscription: fs], not is_nil(fs.activated_at)
  end

  # by field values

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [feed_subscription: fs], fs.id == ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [feed_subscription: fs], fs.id in ^ids
  end

  def filter(q, {:feed_id, id}) when is_binary(id) do
    where q, [feed_subscription: fs], fs.feed_id == ^id
  end

  def filter(q, {:feed_id, ids}) when is_list(ids) do
    where q, [feed_subscription: fs], fs.feed_id in ^ids
  end

  def filter(q, {:subscriber_id, id}) when is_binary(id) do
    where q, [feed_subscription: fs], fs.subscriber_id == ^id
  end

  def filter(q, {:subscriber_id, ids}) when is_list(ids) do
    where q, [feed_subscription: fs], fs.subscriber_id in ^ids
  end

end
