# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.FeaturesResolver do
  @moduledoc """
  Performs the GraphQL Community queries.
  """
  alias MoodleNet.{Features, GraphQL}
  alias MoodleNet.GraphQL.{Flow, FetchFields}
  alias MoodleNet.Meta.Pointers

  def feature(%{feature_id: id}, _info), do: Features.one(id: id)

  def features(_args, _info) do
    Features.page(
      &(&1.id),
      [],
      [join: :context, order: :timeline_desc, prefetch: :context]
    )
  end

  def feature_count_edge(%{id: id}, _, info) do
    Flow.fields __MODULE__, :fetch_feature_count_edge, id, info, default: 0
  end

  def fetch_feature_count_edge(_, ids) do
    FetchFields.run(
      %FetchFields{
        queries: Features.Queries,
        query: Features.Feature,
        group_fn: &(&1.context_id),
        map_fn: &(&1.count),
        filters: [context_id: ids],
      }
    )
  end

  def create_feature(%{context_id: id}, info) do
    with {:ok, user} <- GraphQL.admin_or_not_permitted(info),
         {:ok, context} <- Pointers.one(id: id) do
      Features.create(user, context, %{is_local: true})
    end
  end

end
