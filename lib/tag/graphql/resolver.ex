# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Tag.GraphQL.TagResolver do
  @moduledoc "GraphQL tag and Country queries"
  alias MoodleNet.{GraphQL, Repo}

  alias MoodleNet.GraphQL.{
    CommonResolver,
    FetchFields,
    FetchPage,
    FetchPages,
    ResolveField,
    ResolveFields,
    ResolvePage,
    ResolvePages,
    ResolveRootPage
  }

  alias Tag.{Taggable, Taggables}

  def tag(%{tag_id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_tag,
      context: id,
      info: info
    })
  end

  def tag(%{taxonomy_tag_id: tid}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_tag_via_taxonomy,
      context: tid,
      info: info
    })
  end

  def tags(page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_tags,
      page_opts: page_opts,
      info: info,
      # popularity
      cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1]
    })
  end

  ## fetchers

  def fetch_tag(info, id) do
    Taggables.get(id)
  end

  def fetch_tag_via_taxonomy(info, tid) do
    Taggables.one(
      # user: GraphQL.current_user(info),
      taxonomy_tag_id: tid
    )
  end

  def fetch_tags(page_opts, info) do
    FetchPage.run(%FetchPage{
      queries: Taggable.Queries,
      query: Taggable,
      # cursor_fn: Tags.cursor,
      page_opts: page_opts,
      # base_filters: [user: GraphQL.current_user(info)],
      data_filters: [:default, page: [desc: [id: page_opts]]]
    })
  end

  def parent_tag(%Taggable{parent_tag_id: id}, _, info) do
    ResolveFields.run(%ResolveFields{
      module: __MODULE__,
      fetcher: :fetch_parent_tag,
      context: id,
      info: info
    })
  end

  def fetch_parent_tag(_, ids) do
    FetchFields.run(%FetchFields{
      queries: Taggable.Queries,
      query: Taggable,
      group_fn: & &1.id,
      filters: [:default, id: ids]
    })
  end

  @doc "List child tags"
  def tag_children(%{id: id}, %{} = page_opts, info) do
    # IO.inspect(info)
    ResolvePages.run(%ResolvePages{
      module: __MODULE__,
      fetcher: :fetch_tags_children,
      context: id,
      page_opts: page_opts,
      info: info
    })
  end

  def fetch_tags_children(page_opts, info, id) do
    user = GraphQL.current_user(info)

    FetchPage.run(%FetchPage{
      queries: Taggable.Queries,
      query: Taggable,
      # cursor_fn: Tags.cursor(:followers),
      page_opts: page_opts,
      base_filters: [parent_tag: id, user: user],
      data_filters: [:default, page: [desc: [id: page_opts]]]
    })
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