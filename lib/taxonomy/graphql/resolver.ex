# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Taxonomy.GraphQL.TagsResolver do
  @moduledoc "GraphQL tag and Country queries"
  alias MoodleNet.{GraphQL, Repo}
  alias MoodleNet.GraphQL.{
    CommonResolver,
    Flow,
    FetchFields,
    FetchPage,
    FetchPages,
    ResolveField,
    ResolveFields,
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

  def tag(%{character_id: character}, info) do
    ResolveField.run(
      %ResolveField{
        module: __MODULE__,
        fetcher: :fetch_tag_by_character,
        context: character,
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

  def fetch_tag_by_character(info, character_id) do
    Tags.one(
      # user: GraphQL.current_user(info),
      character_id: character_id
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

  def parent_tag(%Tag{parent_tag_id: id}, _, info) do
    ResolveFields.run(
      %ResolveFields{
        module: __MODULE__,
        fetcher: :fetch_parent_tag,
        context: id,
        info: info,
      }
    )
  end

  def fetch_parent_tag(_, ids) do
    FetchFields.run(
      %FetchFields{
        queries: Tags.Queries,
        query: Tag,
        group_fn: &(&1.id),
        filters: [id: ids],
      }
    )
  end

  @doc "List all child tags"
  def tag_children(%{id: id}, %{}=page_opts, info) do
    # IO.inspect(info)
    ResolvePages.run(
      %ResolvePages{
        module: __MODULE__,
        fetcher: :fetch_tags_children,
        context: id,
        page_opts: page_opts,
        info: info,
      }
    )
  end

  def fetch_tags_children(page_opts, info, id) do
    user = GraphQL.current_user(info)
    FetchPage.run(
      %FetchPage{
        queries: Tags.Queries,
        query: Tag,
        # cursor_fn: Tags.cursor(:followers),
        page_opts: page_opts,
        base_filters: [parent_tag: id, user: user],
        # data_filters: [:default, page: [desc: [id: page_opts]]],
      }
    )
  end  

  @doc "List child tags that already have a character"
  def character_tags_edge(%{id: id}, %{}=page_opts, info) do
    # IO.inspect(info)
    ResolvePages.run(
      %ResolvePages{
        module: __MODULE__,
        fetcher: :fetch_character_tags_edge,
        context: id,
        page_opts: page_opts,
        info: info,
      }
    )
  end

  def fetch_character_tags_edge(page_opts, info, ids) do
    user = GraphQL.current_user(info)
    FetchPage.run(
      %FetchPage{
        queries: Tags.Queries,
        query: Tag,
        # cursor_fn: Tags.cursor(:followers),
        page_opts: page_opts,
        base_filters: [context: ids, user: user],
        # data_filters: [:default, page: [desc: [id: page_opts]]],
      }
    )
  end


  def characterise_tag(%{tag_id: id}, info) do
    Repo.transact_with fn ->
      with {:ok, me} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, tag} <- Tags.one(id: id) do
        Tags.characterise(me, tag)  
      end
    end
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
