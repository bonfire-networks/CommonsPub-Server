# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommonResolver do
  alias Ecto.ULID
  alias MoodleNet.GraphQL

  alias MoodleNet.GraphQL.{
    Fields,
    # Pages,
    # FetchFields,
    # FetchPage,
    ResolveFields,
    ResolvePages
  }

  alias MoodleNet.Likes.Like
  alias MoodleNet.Follows.Follow
  alias MoodleNet.Flags.Flag
  alias MoodleNet.Threads.{Comment, Thread}
  alias MoodleNet.Meta.Pointers

  def created_at_edge(%{id: id}, _, _), do: ULID.timestamp(id)

  def context_edge(%{context_id: id}, _, info) do
    ResolveFields.run(%ResolveFields{
      module: __MODULE__,
      fetcher: :fetch_context_edge,
      context: id,
      info: info
    })
  end

  def fetch_context_edge(_, ids) do
    {:ok, ptrs} = Pointers.many(id: flatten(ids))
    Fields.new(Pointers.follow!(ptrs), &Map.get(&1, :id))
  end

  def context_edges(%{context_ids: ids}, %{} = page_opts, info) do
    IO.inspect(context_edges: ids)

    ResolvePages.run(%ResolvePages{
      module: __MODULE__,
      fetcher: :fetch_context_edges,
      context: ids,
      page_opts: page_opts,
      info: info
    })
  end

  def fetch_context_edges(_page_opts, _info, pointers)
      when is_list(pointers) and length(pointers) > 0 and is_struct(hd(pointers)) do
    # means we're already being passed pointers? instead of ids
    IO.inspect(pointers_already: pointers)
    follow_context_edges(pointers)
  end

  def fetch_context_edges(_page_opts, _info, ids) do
    IO.inspect(context_ids: ids)
    flattened_ids = flatten(ids)
    # IO.inspect(flattened: flattened_ids)
    {:ok, pointers} = Pointers.many(id: flattened_ids)
    follow_context_edges(pointers)
  end

  def follow_context_edges(pointers) do
    IO.inspect(context_pointers: pointers)
    contexts = Pointers.follow!(pointers)
    IO.inspect(contexts_final: contexts)
    {:ok, contexts}
    # edge = Fields.new(ptsd, &Map.get(&1, :id))
    # IO.inspect(edge: edge)
    # edge
  end

  @doc """
  Flattens a list by recursively flattening the head and tail of the list
  TODO: move to utlity module
  """
  def flatten([head | tail]), do: flatten(head) ++ flatten(tail)
  def flatten([]), do: []
  def flatten(element), do: [element]

  # defp preload_context(%{context: %NotLoaded{}}=me), do: Repo.preload(me, :context)
  # defp preload_context(%{context: %{}}=me), do: me
  # defp preload_context(me), do: Repo.preload(me, :context)

  # def loaded_context(%Community{}=community), do: Repo.preload(community, :actor)
  # def loaded_context(%Collection{}=collection), do: Repo.preload(collection, :actor)
  # def loaded_context(%User{}=user), do: Repo.preload(user, :actor)
  # def loaded_context(other), do: other

  # def tag(%{tag_id: id}, info) do
  #   {:ok, Simulation.tag()}
  #   |> GraphQL.response(info)
  # end
  # def tag_category(%{tag_category_id: id}, info) do
  #   {:ok, Simulation.tag_category()}
  #   |> GraphQL.response(info)
  # end
  # def tag_category(_, _, info) do
  #   {:ok, Simulation.tag_category()}
  #   |> GraphQL.response(info)
  # end
  # def tagging(%{tagging_id: id}, info) do
  #   {:ok, Simulation.tagging()}
  #   |> GraphQL.response(info)
  # end
  # def taggings(_, _, info) do
  #   {:ok, Simulation.long_edge_list(&Simulation.tagging/0)}
  #   |> GraphQL.response(info)
  # end

  def is_public_edge(parent, _, _), do: {:ok, not is_nil(parent.published_at)}
  def is_local_edge(%{is_local: is_local}, _, _), do: {:ok, is_local}
  def is_disabled_edge(parent, _, _), do: {:ok, not is_nil(parent.disabled_at)}
  def is_hidden_edge(parent, _, _), do: {:ok, not is_nil(parent.hidden_at)}
  def is_deleted_edge(parent, _, _), do: {:ok, not is_nil(parent.deleted_at)}

  # def followed(%Follow{}=follow,_,info)

  def delete(%{context_id: id}, info) do
    with {:ok, user} <- GraphQL.current_user_or_not_logged_in(info),
         {:ok, pointer} <- Pointers.one(id: id) do
      context = Pointers.follow!(pointer)

      if allow_delete?(user, context) do
        apply(context.__struct__, :context_module, [])
        |> apply(:soft_delete, [user, context])
      else
        GraphQL.not_permitted("delete")
      end
    end
  end

  # FIXME: boilerplate code
  defp allow_delete?(user, context) do
    user.local_user.is_instance_admin or allow_user_delete?(user, context)
  end

  defp allow_user_delete?(user, %type{creator_id: creator_id} = _context) do
    type in [Flag, Like, Follow, Thread, Comment] and creator_id == user.id
  end

  defp allow_user_delete?(_, _), do: false

  # def tag(_, _, info) do
  #   {:ok, Simulation.tag()}
  #   |> GraphQL.response(info)
  # end

  # def create_tagging(_, info) do
  #   {:ok, Simulation.tagging()}
  #   |> GraphQL.response(info)
  # end

  # def tags(parent, _, info) do
  #   {:ok, Simulation.long_edge_list(&Simulation.tagging/0)}
  #   |> GraphQL.response(info)
  # end
end
