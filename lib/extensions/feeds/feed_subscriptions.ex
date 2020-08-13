# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Feeds.FeedSubscriptions do

  alias MoodleNet.Repo
  alias MoodleNet.Feeds.{FeedSubscription, FeedSubscriptionsQueries}
  alias MoodleNet.Users.User

  def one(filters) do
    Repo.single(FeedSubscriptionsQueries.query(FeedSubscription, filters))
  end

  def many(filters \\ []) do
    {:ok, Repo.all(FeedSubscriptionsQueries.query(FeedSubscription, filters))}
  end

  def create(%{id: subscriber_id}, feed_id, attrs) do
    attrs = Map.put(attrs, :is_active, true)
    FeedSubscription.create_changeset(subscriber_id, feed_id, attrs)
    |> Repo.insert()
  end

  def update_by(%User{}, filters, updates) do
    Repo.delete_all(FeedSubscriptionsQueries.query(FeedSubscription, filters), set: updates)
  end

  def soft_delete_by(%User{}=user, filters) do
    update_by(user, [{:deleted, false}, filters], deleted_at: DateTime.utc_now())
    :ok
  end

end
