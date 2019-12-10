# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Feeds do

  alias MoodleNet.Feeds.{Feed, FeedActivity, FeedSubscription}
  alias MoodleNet.Repo
  alias Ecto.ULID
  import Ecto.Query
  
  def fetch_feed(id), do: Repo.fetch(Feed, id)

  def fetch_sub(id), do: Repo.fetch(FeedSubscription, id)
  
  def create_feed(), do: Repo.insert(Feed.create_changeset())

  def create_sub() do
  end

  # returns a list of feed ids
  def active_subs_for(%{id: id}) do
    Repo.all(active_subs_for_q(id))
  end

  defp active_subs_for_q(id) do
    FeedSubscription
    |> active_subs_for_common(id)
    |> select([s], s.feed_id)
  end

  def feed_activities(feed_id, opts \\ %{})
  def feed_activities(feed_id, %{}=opts) when is_binary(feed_id),
    do: feed_activities([feed_id], opts)

  def feed_activities(feed_ids, %{}=opts) when is_list(feed_ids) do
    feed_activities_q(feed_ids)
    |> feed_activities_opts(opts)
    |> Repo.all()
  end

  def publish_to_feeds(feed_targets, activity) when is_list(feed_targets) do
    to_insert =
      feed_targets
      |> Enum.flat_map(&publish_to_feed_activity(activity.id, &1))
    with {_,_} <- Repo.insert_all(FeedActivity, to_insert) do
      :ok
    end
  end

  defp publish_to_feed_activity(_, nil), do: []

  defp publish_to_feed_activity(activity, id) when is_binary(id) do
    [%{feed_id: id, activity_id: activity, id: ULID.generate()}]
  end

  defp publish_to_feed_activity(activity, %{outbox_id: id}) do
    publish_to_feed_activity(activity, id)
  end

  defp feed_activities_q(feed_ids) do
    from f in FeedActivity,
      join: a in assoc(f, :activity),
      where: not is_nil(a.published_at),
      where: f.feed_id in ^feed_ids,
      select: f,
      preload: [:activity]
  end

  # defp feed_activities_count_q(feed_ids) do
  # end

  # defp feed_activities_opts(query, %{after: cursor}) do
    
  # end
  # defp feed_activities_opts(query, %{before: cursor}) do
    
  # end

  defp feed_activities_opts(query, %{}=opts) do
    query
  end

  # @max_limit 100
  # defp get_limit(%{}=opts) do
  #   case Map.get(opts, :limit) do
  #     nil
  #   end
  # end

  # defp active_subscriptions_for_previous_cursor_q(subscriber_id, cursor) do
  #   Subscription
  #   |> where([s], s.id < ^cursor)
  #   |> active_subscriptions_for_common(subscriber_id)
  #   |> select([s], s.id)
  #   |> subquery()
  # end

  defp active_subs_for_common(query, subscriber_id) do
    query
    |> where([s], is_nil(s.deleted_at))
    |> where([s], not is_nil(s.activated_at))
    |> where([s], s.subscriber_id == ^subscriber_id)
  end

end
