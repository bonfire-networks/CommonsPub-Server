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
  alias MoodleNet.Common

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
    {:ok, ptrs} = Pointers.many(id: List.flatten(ids))
    Fields.new(Pointers.follow!(ptrs), &Map.get(&1, :id))
  end

  def context_edges(%{context_ids: ids}, %{} = page_opts, info) do
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
    follow_context_edges(pointers)
  end

  def fetch_context_edges(_page_opts, _info, ids) do
    flattened_ids = List.flatten(ids)
    {:ok, pointers} = Pointers.many(id: flattened_ids)
    follow_context_edges(pointers)
  end

  def follow_context_edges(pointers) do
    contexts = Pointers.follow!(pointers)
    {:ok, contexts}
  end

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
         {:ok, deleted} <- Common.trigger_soft_delete(id, user) do
      {:ok, deleted}
    else
      e ->
        IO.inspect(cannot_delete: e)
        GraphQL.not_permitted("delete")
    end
  end

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
