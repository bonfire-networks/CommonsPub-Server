# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Feeds.FeedSubscriptions do

  alias MoodleNet.{Repo, Feeds}
  alias MoodleNet.Feeds.{FeedSubscription, FeedSubscriptionsQueries}
  import Ecto.Query

  def one(filters) do
    Repo.single(FeedSubscriptionsQueries.query(FeedSubscription, filters))
  end

  def many(filters \\ []) do
    {:ok, Repo.all(FeedSubscriptionsQueries.query(FeedSubscription, filters))}
  end

  def create(%{id: subscriber_id}=subscriber, feed_id, attrs) do
    Repo.insert(FeedSubscription.create_changeset(subscriber_id, feed_id, %{is_active: true}))
  end

end
