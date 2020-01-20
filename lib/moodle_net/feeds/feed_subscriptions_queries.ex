# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Feeds.FeedSubscriptionsQueries do
  alias MoodleNet.Feeds.FeedSubscription
  alias MoodleNet.Users.{LocalUser, User}
  import Ecto.Query

  def query(FeedSubscription) do
    from fs in FeedSubscription, as: :like
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
    where q, [like: l], is_nil(l.deleted_at)
  end

  def filter(q, :disabled) do
    where q, [like: l], is_nil(l.disabled_at)
  end

  def filter(q, :inactive) do
    where q, [like: l], not is_nil(l.activated_at)
  end

  # by field values

  def filter(q, {:id, id}) when is_binary(id) do
    where q, [like: l], l.id == ^id
  end

  def filter(q, {:id, ids}) when is_list(ids) do
    where q, [like: l], l.id in ^ids
  end

  def filter(q, {:feed_id, id}) when is_binary(id) do
    where q, [like: l], l.feed_id == ^id
  end

  def filter(q, {:feed_id, ids}) when is_list(ids) do
    where q, [like: l], l.feed_id in ^ids
  end

  def filter(q, {:subscriber_id, id}) when is_binary(id) do
    where q, [like: l], l.subscriber_id == ^id
  end

  def filter(q, {:subscriber_id, ids}) when is_list(ids) do
    where q, [like: l], l.subscriber_id in ^ids
  end

end
