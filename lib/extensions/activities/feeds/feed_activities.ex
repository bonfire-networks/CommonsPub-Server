# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Feeds.FeedActivities do
  @moduledoc """
  Handles publishing of activities to feeds/timelines, both in DB and over LiveView/PubSub
  """
  alias CommonsPub.{Repo, Feeds}
  alias CommonsPub.Feeds.{FeedActivity, FeedActivitiesQueries}
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

  @doc "Publish an activity to the feeds with the given ids"
  @spec publish(Activity.t(), feed_ids :: [binary]) :: :ok

  def publish(nil, _), do: :ok

  def publish(activity, feed_ids) when is_list(feed_ids) do
    case Enum.flat_map(feed_ids, &publish_activity(activity, &1)) do
      [] -> :ok
      many -> with {_, _} <- Repo.insert_all(FeedActivity, many), do: :ok
    end
  end

  defp publish_activity(%{id: activity_id} = activity, feed_id)
       when is_binary(feed_id) and is_binary(activity_id) do
    # start already sending it via PubSub
    pubsub_broadcast(feed_id, activity)

    [%{feed_id: feed_id, activity_id: activity_id, id: ULID.generate()}]
  end

  defp publish_activity(_, _), do: []

  def pubsub_broadcast(feed_id, activity) do
    Phoenix.PubSub.broadcast(CommonsPub.PubSub, feed_id, {:pub_feed_activity, activity})
  end

  def default_query_contexts() do
    CommonsPub.Config.get!(Feeds)
    |> Map.fetch!(:default_query_contexts)
  end
end
