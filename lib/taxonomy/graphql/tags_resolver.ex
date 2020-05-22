# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Taxonomy.GraphQL.TagsResolver do
  @moduledoc "GraphQL tag and Country queries"
  alias MoodleNet.{GraphQL}
  alias MoodleNet.GraphQL.{
    CommonResolver,
    Flow,
    FetchFields,
    FetchPage,
    FetchPages,
    ResolveField,
    ResolvePage,
    ResolvePages,
    ResolveRootPage,
  }

  alias Taxonomy.{Tag, Tags}

  def tag(%{tag_id: id}, info) do
    ResolveField.run(
      %ResolveField{
        module: __MODULE__,
        fetcher: :fetch_tag,
        context: id,
        info: info,
      }
    )
  end

  def tags(page_opts, info) do
    ResolveRootPage.run(
      %ResolveRootPage{
        module: __MODULE__,
        fetcher: :fetch_tags,
        page_opts: page_opts,
        info: info,
        cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1], # popularity
      }
    )
  end

  ## fetchers

  def fetch_tag(info, id) do
    Tags.one(
      # user: GraphQL.current_user(info),
      id: id,
    )
  end

  def fetch_tags(page_opts, info) do
    FetchPage.run(
      %FetchPage{
        queries: Tags.Queries,
        query: Tag,
        # cursor_fn: Tags.cursor,
        page_opts: page_opts,
        # base_filters: [user: GraphQL.current_user(info)],
        # data_filters: [page: [desc: [followers: page_opts]]],
      }
    )
  end

  # def tag(%{tag_id: id}, info) do
  #   {:ok, Fake.tag()}
  #   |> GraphQL.response(info)
  # end

  # def search_tag(%{query: id}, info) do
  #   {:ok, Fake.long_node_list(&Fake.tag/0)}
  #   |> GraphQL.response(info)
  # end



end
