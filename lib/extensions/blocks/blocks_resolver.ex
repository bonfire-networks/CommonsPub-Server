# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Web.GraphQL.BlocksResolver do
  alias CommonsPub.{Blocks, GraphQL, Repo}
  alias CommonsPub.Blocks.Block

  alias CommonsPub.GraphQL.{
    FetchFields,
    FetchPage,
    # FetchPages,
    ResolveFields,
    ResolveRootPage,
    ResolvePages
  }

  alias CommonsPub.Meta.Pointers
  alias CommonsPub.Users.User

  def block(%{block_id: id}, info) do
    with {:ok, %User{} = user} <- GraphQL.current_user_or_not_found(info) do
      Blocks.one(id: id, user: user)
    end
  end

  def blocks(%{} = page_opts, info) do
    with {:ok, _user} <- GraphQL.admin_or_not_permitted(info) do
      ResolveRootPage.run(%ResolveRootPage{
        module: __MODULE__,
        fetcher: :fetch_blocks,
        page_opts: page_opts,
        info: info
      })
    else
      {:error, _} -> GraphQL.empty_page()
    end
  end

  def fetch_blocks(page_opts, _info) do
    FetchPage.run(%FetchPage{
      queries: Blocks.Queries,
      query: Block,
      cursor_fn: &[&1.id],
      page_opts: page_opts,
      base_filters: [deleted: false],
      data_filters: [page: [desc: [created: page_opts]]]
    })
  end

  def blocks_edge(%{id: id}, %{} = page_opts, info) do
    with {:ok, %User{}} <- GraphQL.current_user_or_empty_page(info) do
      ResolvePages.run(%ResolvePages{
        module: __MODULE__,
        fetcher: :fetch_blocks_edge,
        context: id,
        page_opts: page_opts,
        info: info
      })
    end
  end

  # def fetch_blocks_edge({page_opts, info}, ids) do
  #   user = GraphQL.current_user(info)
  #   FetchPages.run(
  #     %FetchPages{
  #       queries: Blocks.Queries,
  #       query: Block,
  #       cursor_fn: &[&1.id],
  #       group_fn: &(&1.context_id),
  #       page_opts: page_opts,
  #       base_filters: [deleted: false, user: user, creator: ids],
  #       data_filters: [page: [desc: [created: page_opts]]],
  #       count_filters: [group_count: :creator_id],
  #     }
  #   )
  # end

  def fetch_blocks_edge(page_opts, info, ids) do
    user = GraphQL.current_user(info)

    FetchPage.run(%FetchPage{
      queries: Blocks.Queries,
      query: Block,
      cursor_fn: &[&1.id],
      page_opts: page_opts,
      base_filters: [deleted: false, user: user, context: ids],
      data_filters: [page: [desc: [created: page_opts]]]
    })
  end

  def my_block_edge(%{id: id}, _, info) do
    with {:ok, %User{}} <- GraphQL.current_user_or(info, nil) do
      ResolveFields.run(%ResolveFields{
        module: __MODULE__,
        fetcher: :fetch_my_block_edge,
        context: id,
        info: info
      })
    end
  end

  def fetch_my_block_edge(info, ids) do
    with %User{} = user <- GraphQL.current_user(info) do
      FetchFields.run(%FetchFields{
        queries: Blocks.Queries,
        query: Block,
        group_fn: & &1.context_id,
        filters: [deleted: false, creator: user.id, context: ids]
      })
    end
  end

  # TODO: store community id where appropriate
  def create_block(%{context_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, me} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, pointer} <- Pointers.one(id: id) do
        Blocks.create(me, pointer, %{is_blocked: true, is_local: true, is_public: false})
      end
    end)
  end
end
