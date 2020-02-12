# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.FlagsResolver do

  alias MoodleNet.{Batching, Flags, GraphQL, Repo}
  alias MoodleNet.Flags.Flag
  alias MoodleNet.Batching.{Edges, EdgesPage, EdgesPages}
  alias MoodleNet.Meta.Pointers
  alias MoodleNet.Users.User
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  def flag(%{flag_id: id}, info) do
    with {:ok, %User{}=user} <- GraphQL.current_user_or(info, nil) do
      Flags.one(id: id, user: user)
    end
  end

  def flags_edge(%{id: id}, %{}=page_opts, info) do
    with {:ok, %User{}=user} <- GraphQL.current_user_or_empty_edge_list(info) do
      if GraphQL.in_list?(info) do
        with {:ok, page_opts} <- Batching.limit_page_opts(page_opts) do
          batch {__MODULE__, :batch_flags_edge, {page_opts,user}}, id, EdgesPages.getter(id)
        end
      else
        with {:ok, page_opts} <- Batching.full_page_opts(page_opts) do
          single_flags_edge(page_opts, user, id)
        end
      end
    end
  end

  def single_flags_edge(page_opts, user, ids) do
    Flags.edges_page(
      &(&1.id),
      page_opts,
      [user: user, context_id: ids],
      [order: :timeline_desc]
    )
  end

  def batch_flags_edge({page_opts, user}, ids) do
    {:ok, edges} = Flags.edges_pages(
      &(&1.context_id),
      &(&1.id),
      page_opts,
      [:deleted, user: user, context_id: ids],
      [order: :timeline_desc],
      [group_count: :context_id]
    )
    edges
  end

  def is_resolved_edge(%Flag{}=flag, _, _), do: {:ok, not is_nil(flag.resolved_at)}

  def my_flag_edge(%{id: id}, _, info) do
    with {:ok, %User{}=user} <- GraphQL.current_user_or(info, nil) do
      batch {__MODULE__, :batch_my_flag_edge, user}, id, Edges.getter(id)
    end
  end

  def batch_my_flag_edge(_user, []), do: %{}
  def batch_my_flag_edge(%User{id: id}, ids) do
    {:ok, edges} = Flags.edges(&(&1.context_id), [:deleted, creator_id: id, context_id: ids])
    edges
  end

  # TODO: store community id where appropriate
  def create_flag(%{context_id: id, message: message}, info) do
    Repo.transact_with(fn ->
      with {:ok, me} <- GraphQL.current_user(info),
           {:ok, pointer} <- Pointers.one(id: id) do
        Flags.create(me, pointer, %{message: message, is_local: true})
      end
    end)
  end

end
