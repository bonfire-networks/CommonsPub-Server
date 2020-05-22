# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.FeaturesResolver do
  @moduledoc """
  Performs the GraphQL Community queries.
  """
  alias MoodleNet.{Features, GraphQL}
  alias MoodleNet.GraphQL.{FetchFields, ResolveFields, ResolveRootPage, FetchPage}
  alias MoodleNet.Meta.Pointers

  def feature(%{feature_id: id}, _info), do: Features.one(id: id)

  def features(%{} = page_opts, info) do
    with {:ok, _user} <- GraphQL.current_user_or_empty_page(info) do
      ResolveRootPage.run(
          %ResolveRootPage{
            module: __MODULE__,
            fetcher: :fetch_features,
            page_opts: page_opts,
            info: info
          }
        )
    end
  end

  def fetch_features(page_opts, _info) do
    FetchPage.run(
      %FetchPage{
        queries: Features.Queries,
        query: Features.Feature,
        cursor_fn: &[&1.id],
        page_opts: page_opts
      }
    )
  end

  def feature_count_edge(%{id: id}, _, info) do
    ResolveFields.run(
      %ResolveFields{
        module: __MODULE__,
        fetcher: :fetch_feature_count_edge,
        context: id,
        info: info,
        default: 0,
      }
    )
  end

  def fetch_feature_count_edge(_, ids) do
    FetchFields.run(
      %FetchFields{
        queries: Features.Queries,
        query: Features.Feature,
        group_fn: &(&1.context_id),
        map_fn: &(&1.count),
        filters: [context: ids],
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
