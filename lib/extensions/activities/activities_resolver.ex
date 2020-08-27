# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ActivitiesResolver do
  alias MoodleNet.Activities
  alias MoodleNet.Activities.Activity
  alias MoodleNet.GraphQL.{Fields, ResolveFields}
  alias MoodleNet.Meta.Pointers

  alias MoodleNet.GraphQL.{FetchPage}

  def activity(%{activity_id: id}, %{context: %{current_user: user}}) do
    Activities.one(id: id, user: user)
  end

  def context_edge(%Activity{context: context}, _, info) do
    ResolveFields.run(%ResolveFields{
      module: __MODULE__,
      fetcher: :fetch_context_edge,
      context: context,
      info: info
    })
  end

  def fetch_context_edge(_, contexts) do
    Fields.new(Pointers.follow!(contexts), &Map.get(&1, :id))
  end

  def fetch_outbox_edge(feed_id, tables, page_opts) do
    FetchPage.run(%FetchPage{
      queries: Activities.Queries,
      query: Activities.Activity,
      page_opts: page_opts,
      base_filters: [deleted: false, feed_timeline: feed_id, table: tables],
      data_filters: [page: [desc: [created: page_opts]], preload: :context]
    })
  end
end
