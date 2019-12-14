# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Feeds do

  alias MoodleNet.Feeds.{Feed, FeedActivity, FeedSubscription}
  alias MoodleNet.Meta.TableService
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Comments.Comment
  alias MoodleNet.Communities.Community
  alias MoodleNet.Flags.Flag
  alias MoodleNet.Follows.Follow
  alias MoodleNet.Likes.Like
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Repo
  alias Ecto.ULID
  import Ecto.Query
  
  def fetch_feed(id), do: Repo.fetch(Feed, id)

  def fetch_sub(id), do: Repo.fetch(FeedSubscription, id)
  
  def find_sub(%{id: subscriber_id}, feed_id) do
    Repo.single(find_sub_q(subscriber_id, feed_id))
  end

  defp find_sub_q(subscriber_id, feed_id) do
    from s in FeedSubscription,
      where: s.subscriber_id == ^subscriber_id,
      where: s.feed_id == ^feed_id,
      where: not is_nil(s.activated_at)
  end
    
  def create_feed(), do: Repo.insert(Feed.create_changeset())

  def create_sub(%{id: subscriber_id}=subscriber, feed_id, attrs) do
    Repo.insert(FeedSubscription.create_changeset(subscriber_id, feed_id, %{is_active: true}))
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

  @default_activity_contexts [
    Collection, Comment, Community, Resource, Flag, Follow, Like
  ]
  def feed_activities(feed_id, opts \\ %{})
  def feed_activities(feed_id, %{}=opts) when is_binary(feed_id),
    do: feed_activities([feed_id], opts)

  def feed_activities(feed_ids, %{}=opts) when is_list(feed_ids) do
    feed_activities_q(feed_ids, opts)
    |> Repo.all()
  end

  defp table_ids(schemas), do: Enum.map(&TableService.lookup_id!/1)

  @spec publish_to_feeds(feed_ids :: [binary], Activity.t) :: :ok
  def publish_to_feeds(feed_ids, activity) when is_list(feed_ids) do
    case Enum.flat_map(feed_ids, &publish_to_feed_activity(activity.id, &1)) do
      [] -> :ok
      many -> with {_,_} <- Repo.insert_all(FeedActivity, many), do: :ok
    end        
  end

  defp publish_to_feed_activity(_, nil), do: []

  defp publish_to_feed_activity(activity, id) when is_binary(id) do
    [%{feed_id: id, activity_id: activity, id: ULID.generate()}]
  end

  defp feed_activities_q(feed_ids, opts) do
    table_ids =
      Map.get(opts, :contexts, @default_activity_contexts)
      |> Enum.map(&TableService.lookup_id!/1)

    from f in FeedActivity,
      join: a in assoc(f, :activity),
      join: c in assoc(a, :context),
      where: not is_nil(a.published_at),
      where: f.feed_id in ^feed_ids,
      where: c.table_id in ^table_ids,
      select: f,
      preload: [activity: {a, context: c}]
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
