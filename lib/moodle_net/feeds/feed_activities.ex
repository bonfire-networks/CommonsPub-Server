# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Feeds.FeedActivities do

  alias MoodleNet.{Repo, Feeds}
  alias MoodleNet.Feeds.{FeedActivity, FeedActivitiesQueries}
  alias Ecto.ULID
  

  @doc """
  Retrieves a single feed activity by arbitrary filters.
  Used by:
  * GraphQL Item queries
  * ActivityPub integration
  * Various parts of the codebase that need to query for feed activities (inc. tests)
  """
  def one(filters), do: Repo.single(FeedActivitiesQueries.query(FeedActivity, filters))

  @doc """
  Retrieves a list of feed activities by arbitrary filters.
  Used by:
  * Various parts of the codebase that need to query for feed activities (inc. tests)
  """
  def many(filters), do: {:ok, Repo.all(FeedActivitiesQueries.query(FeedActivity, filters))}

  def update_by(filters, updates \\ []) do
    Repo.update_all(FeedActivitiesQueries.query(FeedActivity, filters), set: updates)
  end

  def update_by(filters, updates \\ []) do
    FeedActivitiesQueries.query(FeedActivity)
    |> FeedActivitiesQueries.filter(filters)
    |> Repo.update_all(updates)
  end

  @doc false
  def hard_delete() do
    FeedActivitiesQueries.query(FeedActivity)
    |> FeedActivitiesQueries.filter(:hard_delete)
    |> Repo.delete_all()
  end

  @doc "Publish an activity to the feeds with the given ids"
  @spec publish(Activity.t, feed_ids :: [binary]) :: :ok
  def publish(activity, feed_ids) when is_list(feed_ids) do
    case Enum.flat_map(feed_ids, &publish_activity(activity.id, &1)) do
      [] -> :ok
      many -> with {_,_} <- Repo.insert_all(FeedActivity, many), do: :ok
    end
  end

  defp publish_activity(_, nil), do: []

  defp publish_activity(activity, id) when is_binary(id) do
    [%{feed_id: id, activity_id: activity, id: ULID.generate()}]
  end

  def default_query_contexts() do
    Application.fetch_env!(:moodle_net, Feeds)
    |> Map.fetch!(:default_query_contexts)
  end

end

