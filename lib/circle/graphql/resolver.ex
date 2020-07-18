# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Circle.GraphQL.Resolver do
  alias MoodleNet.{
    # Activities,
    GraphQL,
    Repo
    # Resources
  }

  alias MoodleNet.GraphQL.{
    # CommonResolver,
    # FetchFields,
    FetchPage,
    # FetchPages,
    ResolveField,
    # ResolvePage,
    ResolvePages,
    ResolveRootPage
  }

  alias Circle

  alias Circle.{
    Circles
    # Queries
  }

  # alias MoodleNet.Resources.Resource
  # alias MoodleNet.Common.Enums
  alias Pointers

  ## resolvers

  def circle(%{circle_id: id}, info) do
    ResolveField.run(%ResolveField{
      module: __MODULE__,
      fetcher: :fetch_circle,
      context: id,
      info: info
    })
  end

  def circles(page_opts, info) do
    ResolveRootPage.run(%ResolveRootPage{
      module: __MODULE__,
      fetcher: :fetch_circles,
      page_opts: page_opts,
      info: info,
      # popularity
      cursor_validators: [&(is_integer(&1) and &1 >= 0), &Ecto.ULID.cast/1]
    })
  end

  ## fetchers

  def fetch_circle(info, id) do
    Circles.one(
      user: GraphQL.current_user(info),
      id: id,
      preload: :default
    )
  end

  def fetch_circles(page_opts, info) do
    FetchPage.run(%FetchPage{
      queries: Circle.Queries,
      query: Circle,
      # cursor_fn: Circles.cursor(:followers),
      page_opts: page_opts,
      base_filters: [user: GraphQL.current_user(info)],
      data_filters: [:default, page: page_opts]
    })
  end

  def circles_edge(%{id: id}, %{} = page_opts, info) do
    ResolvePages.run(%ResolvePages{
      module: __MODULE__,
      fetcher: :fetch_circles_edge,
      context: id,
      page_opts: page_opts,
      info: info
    })
  end

  def fetch_circles_edge(page_opts, info, ids) do
    user = GraphQL.current_user(info)

    FetchPage.run(%FetchPage{
      queries: Circle.Queries,
      query: Circle,
      # cursor_fn: Circles.cursor(:followers),
      page_opts: page_opts,
      base_filters: [context: ids, user: user],
      data_filters: [:default, page: [desc: [followers: page_opts]]]
    })
  end

  ## finally the mutations...

  def create_circle(%{circle: attrs, context_id: context_id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, pointer} <- MoodleNet.Meta.Pointers.one(id: context_id),
           :ok <- validate_circle_context(pointer) do
        context = MoodleNet.Meta.Pointers.follow!(pointer)
        Circles.create(user, context, attrs)
      end
    end)
  end

  def create_circle(%{circle: attrs}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info) do
        Circles.create(user, attrs)
      end
    end)
  end

  def update_circle(%{circle: changes, circle_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
           {:ok, circle} <- circle(%{circle_id: id}, info) do
        cond do
          user.local_user.is_instance_admin ->
            Circles.update(user, circle, changes)

          circle.character.creator_id == user.id ->
            Circles.update(user, circle, changes)

          true ->
            GraphQL.not_permitted("update")
        end
      end
    end)
  end

  # def delete(%{circle_id: id}, info) do
  #   # Repo.transact_with(fn ->
  #   #   with {:ok, user} <- GraphQL.current_user(info),
  #   #        {:ok, actor} <- Users.fetch_actor(user),
  #   #        {:ok, circle} <- Circles.fetch(id) do
  #   #     circle = Repo.preload(circle, :community)
  #   # 	permitted =
  #   # 	  user.is_instance_admin or
  #   #       circle.character.creator_id == actor.id or
  #   #       circle.character.context.creator_id == actor.id
  #   # 	if permitted do
  #   # 	  with {:ok, _} <- Circles.soft_delete(circle), do: {:ok, true}
  #   # 	else
  #   # 	  GraphQL.not_permitted()
  #   #     end
  #   #   end
  #   # end)
  #   # |> GraphQL.response(info)
  #   {:ok, true}
  #   |> GraphQL.response(info)
  # end

  defp validate_circle_context(pointer) do
    if Pointers.table(pointer).schema in valid_contexts() do
      :ok
    else
      GraphQL.not_permitted()
    end
  end

  defp valid_contexts do
    Keyword.fetch!(Application.get_env(:moodle_net, Circle), :valid_contexts)
  end
end
