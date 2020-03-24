# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Feeds.FeedActivities do

  alias MoodleNet.{Repo, Feeds}
  alias MoodleNet.Feeds.{FeedActivity, FeedActivitiesQueries}
  alias MoodleNet.GraphQL.{Page, Pages}
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

  @doc """
  Retrieves an EdgesPage of feed activities according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def page(cursor_fn, page_opts, base_filters, data_filters, count_filters)
  when is_function(cursor_fn, 1) do
    {data_q, count_q} = FeedActivitiesQueries.queries(FeedActivity, base_filters, data_filters, count_filters)
    with {:ok, [data, count]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, Page.new(data, count, cursor_fn, page_opts)}
    end
  end

  @doc """
  Retrieves an EdgesPages of feed activities according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def pages(cursor_fn, group_fn, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def pages(cursor_fn, group_fn, base_filters, data_filters, count_filters)
  when is_function(cursor_fn, 1) and is_function(group_fn, 1) do
    {data_q, count_q} = FeedActivitiesQueries.queries(FeedActivity, base_filters, data_filters, count_filters)
    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, all: count_q) do
      {:ok, Pages.new(data, counts, cursor_fn, group_fn)}
    end
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

