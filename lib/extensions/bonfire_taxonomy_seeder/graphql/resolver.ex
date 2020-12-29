# SPDX-License-Identifier: AGPL-3.0-only
defmodule Bonfire.TaxonomySeeder.GraphQL.TaxonomyResolver do
  @moduledoc "GraphQL tag and Country queries"
  alias CommonsPub.{GraphQL, Repo}

  alias Bonfire.GraphQL
  alias Bonfire.GraphQL.{

    FetchFields,
    FetchPage,
    # FetchPages,
    ResolveField,
    ResolveFields,
    # ResolvePage,
    ResolvePages,
    ResolveRootPage
  }

  alias Bonfire.TaxonomySeeder.{TaxonomyTag, TaxonomyTags}

  def tag(%{tag_id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_tag,
      context: id,
      info: info
    })
  end

  def tag(%{pointer_id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_tag_by_pointer,
      context: id,
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

  def fetch_tag(_info, id) do
    TaxonomyTags.get(id)
  end

  def fetch_tag_by_pointer(_info, id) do
    TaxonomyTags.one(
      # user: GraphQL.current_user(info),
      category_id: id,
      filter: :default
    )
  end

  def fetch_tags(page_opts, info) do
    FetchPage.run(%FetchPage{
      queries: TaxonomyTag.Queries,
      query: TaxonomyTag,
      # cursor_fn: TaxonomyTags.cursor,
      page_opts: page_opts,
      base_filters: [user: GraphQL.current_user(info)],
      data_filters: [:default, page: [desc: [id: page_opts]]]
    })
  end

  # def parent_tag(%TaxonomyTag{parent_tag: parent_tag}, _, info) do
  #   {:ok, parent_tag}
  # end

  # in case not preloaded
  def parent_tag(%TaxonomyTag{parent_tag_id: id}, _, info) do
    ResolveFields.run(%ResolveFields{
      module: __MODULE__,
      fetcher: :fetch_parent_tag,
      context: id,
      info: info
    })
  end

  # fallback for when there's no more parents
  def parent_tag(%{} = _tag, _, _info) do
    # IO.inspect(no_parent_tag: tag)
    {:ok, nil}
  end

  def fetch_parent_tag(_, ids) do
    FetchFields.run(%FetchFields{
      queries: TaxonomyTag.Queries,
      query: TaxonomyTag,
      group_fn: & &1.id,
      filters: [:default, id: ids]
    })
  end

  @doc "List all child tags"
  def tag_children(%{id: id}, %{} = page_opts, info) do
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
      queries: TaxonomyTag.Queries,
      query: TaxonomyTag,
      # cursor_fn: TaxonomyTags.cursor(:followers),
      page_opts: page_opts,
      base_filters: [parent_tag: id, user: user],
      data_filters: [:default, page: [desc: [id: page_opts]]]
    })
  end

  # @doc "List child tags that already have a character"
  # def character_tags_edge(%{id: id}, %{} = page_opts, info) do
  #   ResolvePages.run(%ResolvePages{
  #     module: __MODULE__,
  #     fetcher: :fetch_character_tags_edge,
  #     context: id,
  #     page_opts: page_opts,
  #     info: info
  #   })
  # end

  # def fetch_character_tags_edge(page_opts, info, ids) do
  #   user = GraphQL.current_user(info)

  #   FetchPage.run(%FetchPage{
  #     queries: TaxonomyTag.Queries,
  #     query: TaxonomyTag,
  #     # cursor_fn: TaxonomyTags.cursor(:followers),
  #     page_opts: page_opts,
  #     base_filters: [context: ids, user: user]
  #     # data_filters: [:default, page: [desc: [id: page_opts]]],
  #   })
  # end

  def ingest_taxonomy_tag(%{taxonomy_tag_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, me} <- GraphQL.current_user_or_not_logged_in(info) do
        TaxonomyTags.maybe_make_category(me, id)
      end
    end)
  end

  # def tag(%{tag_id: id}, info) do
  #   {:ok, Simulate.tag()}
  #   |> GraphQL.response(info)
  # end

  # def search_tag(%{query: id}, info) do
  #   {:ok, Simulate.long_node_list(&Simulate.tag/0)}
  #   |> GraphQL.response(info)
  # end
end
