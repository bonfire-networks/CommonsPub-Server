# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Feeds.FeedSubscriptions do
  alias CommonsPub.Repo
  alias CommonsPub.Feeds.{FeedSubscription, FeedSubscriptionsQueries}
  alias CommonsPub.Users.User

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

  def soft_delete_by(%User{} = user, filters) do
    update_by(user, [{:deleted, false}, filters], deleted_at: DateTime.utc_now())
    :ok
  end
end
