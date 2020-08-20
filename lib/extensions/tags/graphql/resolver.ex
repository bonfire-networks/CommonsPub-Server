# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Tag.GraphQL.TagResolver do
  @moduledoc "GraphQL tag/category queries"
  alias MoodleNet.{GraphQL, Repo}

  alias MoodleNet.GraphQL.{
    # CommonResolver,
    FetchFields,
    FetchPage,
    # FetchPages,
    ResolveField,
    ResolveFields,
    # ResolvePage,
    ResolvePages,
    ResolveRootPage
  }

  alias CommonsPub.Tag.{Category, Categories, Taggable, Taggables}

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

  def taggable(%{id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_taggable,
      context: id,
      info: info
    })
  end

  ## fetchers

  def fetch_taggable(_info, id) do
    Taggables.one(id: id)
  end

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
    # IO.inspect(info)
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

  @doc """
  Things associated with a Tag
  """
  def tagged_things_edges(%Taggable{things: _things} = taggable, %{} = page_opts, info) do
    taggable = Repo.preload(taggable, :things)
    # pointers = for %{id: tid} <- tag.things, do: tid
    pointers =
      taggable.things
      |> Enum.map(fn a -> a.id end)

    # |> Map.new()

    # IO.inspect(pointers)
    MoodleNetWeb.GraphQL.CommonResolver.context_edges(%{context_ids: pointers}, page_opts, info)
  end

  @doc """
  Tags associated with a Thing
  """
  def tags_edges(%{tags: _tags} = thing, page_opts, info) do
    thing = Repo.preload(thing, tags: [:category, :profile, character: [:actor]])

    # IO.inspect(categories_edges_thing: thing)

    tags = Enum.map(thing.tags, &tag_prepare(&1, page_opts, info))

    {:ok, tags}
  end

  def tag_prepare(%{category: %{id: id} = category} = tag, page_opts, info) when not is_nil(id) do
    # TODO: do this better
    Map.merge(
      category,
      %{
        name: tag.profile.name,
        summary: tag.profile.summary,
        prefix: tag.prefix,
        facet: tag.facet,
        character: tag.character,
        profile: tag.profile
      }
    )
  end

  # def tag_prepare(%{profile: %{name: name}} = tag, page_opts, info)
  #     when not is_nil(name) do
  #   Map.merge(
  #     tag,
  #     %{
  #       name: name,
  #       summary: tag.profile.summary
  #     }
  #   )
  # end

  def tag_prepare(%{category_id: category_id, id: mixin_id}, page_opts, info)
      when is_nil(category_id) do
    MoodleNetWeb.GraphQL.CommonResolver.context_edge(%{context_id: mixin_id}, page_opts, info)
  end

  #### MUTATIONS

  def create_category(attrs, info) do
    Repo.transact_with(fn ->
      attrs = Map.merge(attrs, %{is_public: true})

      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, category} <- CommonsPub.Tag.Categories.create(user, attrs) do
        {:ok, category}
      end
    end)
  end

  @doc """
  Turn a Pointer into a Taggable. You can use `thing_attach_tags/2` to tag something with Pointers directly instead.
  """
  def make_pointer_taggable(%{context_id: pointer_id}, info) do
    Repo.transact_with(fn ->
      with {:ok, me} <- GraphQL.current_user_or_not_logged_in(info),
           {ok, taggable} <- CommonsPub.Tag.Taggables.maybe_make_taggable(me, pointer_id, %{}) do
        {:ok, taggable}
      end
    end)
  end

  def thing_attach_tags(%{thing: thing_id, taggables: taggables}, info) do
    with {:ok, me} <- GraphQL.current_user_or_not_logged_in(info),
         {:ok, tagged} = CommonsPub.Tag.TagThings.thing_attach_tags(me, thing_id, taggables) do
      {:ok, true}
    end
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
  #   # IO.inspect(context_id)

  #   # TODO: optimise so it doesn't repeat these queries (for context and summary fields)
  #   with {:ok, pointer} <- MoodleNet.Meta.Pointers.one(id: context_id),
  #        context = MoodleNet.Meta.Pointers.follow!(pointer) do
  #     name = if Map.has_key?(context, :name), do: context.name
  #     # IO.inspect(name)
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
  #   # IO.inspect(context_id)

  #   # TODO: optimise so it doesn't repeat these queries (for context and summary fields)
  #   with {:ok, pointer} <- MoodleNet.Meta.Pointers.one(id: context_id),
  #        context = MoodleNet.Meta.Pointers.follow!(pointer) do
  #     summary = if Map.has_key?(context, :summary), do: context.summary
  #     # IO.inspect(summary)
  #     {:ok, summary}
  #   end
  # end

  def summary(_, _, _) do
    {:ok, nil}
  end

  # def tag(%{tag_id: id}, info) do
  #   {:ok, Simulation.tag()}
  #   |> GraphQL.response(info)
  # end

  # def search_category(%{query: id}, info) do
  #   {:ok, Simulation.long_node_list(&Simulation.tag/0)}
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
