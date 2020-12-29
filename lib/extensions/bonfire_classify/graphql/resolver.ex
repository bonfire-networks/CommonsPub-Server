# SPDX-License-Identifier: AGPL-3.0-only
defmodule Bonfire.Classify.GraphQL.CategoryResolver do
  @moduledoc "GraphQL tag/category queries"

  alias CommonsPub.Repo

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

  alias Bonfire.Classify.{Category, Categories}

  def categories(page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_categories,
      page_opts: page_opts,
      info: info,
      # popularity
      cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1]
    })
  end

  def fetch_categories(page_opts, _info) do
    FetchPage.run(%FetchPage{
      queries: Category.Queries,
      query: Category,
      # cursor_fn: Tags.cursor,
      page_opts: page_opts,
      # base_filters: [user: GraphQL.current_user(info)],
      data_filters: [:default, page: [desc: [id: page_opts]]]
    })
  end

  def categories_toplevel(page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_categories_toplevel,
      page_opts: page_opts,
      info: info,
      # popularity
      cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1]
    })
  end

  def fetch_categories_toplevel(page_opts, _info) do
    FetchPage.run(%FetchPage{
      queries: Category.Queries,
      query: Category,
      # cursor_fn: Tags.cursor,
      page_opts: page_opts,
      # base_filters: [user: GraphQL.current_user(info)],
      data_filters: [:default, :toplevel, page: [desc: [id: page_opts]]]
    })
  end

  def category(%{category_id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_category,
      context: id,
      info: info
    })
  end



  ## fetchers


  def fetch_category(_info, id) do
    Categories.get(id)
  end

  def parent_category(%Category{parent_category_id: id}, _, info) do
    ResolveFields.run(%ResolveFields{
      module: __MODULE__,
      fetcher: :fetch_parent_category,
      context: id,
      info: info
    })
  end

  def fetch_parent_category(_, ids) do
    FetchFields.run(%FetchFields{
      queries: Category.Queries,
      query: Category,
      group_fn: & &1.id,
      filters: [:default, id: ids]
    })
  end

  @doc "List child categories"
  def category_children(%{id: id}, %{} = page_opts, info) do
    ResolvePages.run(%ResolvePages{
      module: __MODULE__,
      fetcher: :fetch_categories_children,
      context: id,
      page_opts: page_opts,
      info: info
    })
  end

  def fetch_categories_children(page_opts, info, id) do
    user = GraphQL.current_user(info)

    FetchPage.run(%FetchPage{
      queries: Category.Queries,
      query: Category,
      # cursor_fn: Tags.cursor(:followers),
      page_opts: page_opts,
      base_filters: [parent_category: id, user: user],
      data_filters: [:default, page: [desc: [id: page_opts]]]
    })
  end


  #### MUTATIONS

  def create_category(attrs, info) do
    Repo.transact_with(fn ->
      attrs = Map.merge(attrs, %{is_public: true})

      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, category} <- Bonfire.Classify.Categories.create(user, attrs) do
        {:ok, category}
      end
    end)
  end


  ### decorators

  def name(%{profile: %{name: name}}, _, _info) when not is_nil(name) do
    {:ok, name}
  end

  def name(%{name: name}, _, _info) when not is_nil(name) do
    {:ok, name}
  end

  # def name(%{name: name, context_id: context_id}, _, _info)
  #     when is_nil(name) and not is_nil(context_id) do

  #   # TODO: optimise so it doesn't repeat these queries (for context and summary fields)
  #   with {:ok, pointer} <- Bonfire.Common.Pointers.one(id: context_id),
  #        context = Bonfire.Common.Pointers.follow!(pointer) do
  #     name = if Map.has_key?(context, :name), do: context.name
  #     {:ok, name}
  #   end
  # end

  def name(_, _, _) do
    {:ok, nil}
  end

  def summary(%{profile: %{summary: summary}}, _, _info) when not is_nil(summary) do
    {:ok, summary}
  end

  def summary(%{summary: summary}, _, _info) when not is_nil(summary) do
    {:ok, summary}
  end

  # def summary(%{summary: summary, context_id: context_id}, _, _info)
  #     when is_nil(summary) and not is_nil(context_id) do

  #   # TODO: optimise so it doesn't repeat these queries (for context and summary fields)
  #   with {:ok, context} <- Bonfire.Common.Pointers.get(context_id) do
  #     summary = if Map.has_key?(context, :summary), do: context.summary
  #     {:ok, summary}
  #   end
  # end

  def summary(_, _, _) do
    {:ok, nil}
  end

  # def search_category(%{query: id}, info) do
  #   {:ok, Simulate.long_node_list(&Simulate.tag/0)}
  #   |> GraphQL.response(info)
  # end

  def update_category(%{category_id: id} = changes, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, category} <- category(%{category_id: id}, info),
           :ok <- ensure_update_allowed(user, category),
           {:ok, c} <- Categories.update(user, category, changes) do
        {:ok, c}
      end
    end)
  end

  def ensure_update_allowed(user, geo) do
    if user.local_user.is_instance_admin or geo.creator_id == user.id do
      :ok
    else
      GraphQL.not_permitted("update")
    end
  end

  # def delete_category(%{id: id}, info) do
  #   with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
  #        {:ok, c} <- category(%{id: id}, info),
  #        :ok <- ensure_delete_allowed(user, c),
  #        {:ok, c} <- Categories.soft_delete(user, c) do
  #     {:ok, true}
  #   end
  # end

  # def ensure_delete_allowed(user, c) do
  #   if user.local_user.is_instance_admin or c.creator_id == user.id do
  #     :ok
  #   else
  #     GraphQL.not_permitted("delete")
  #   end
  # end
end
