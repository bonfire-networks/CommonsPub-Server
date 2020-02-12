# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ThreadsResolver do

  alias MoodleNet.{Batching, GraphQL, Repo, Threads}
  alias MoodleNet.Batching.{EdgesPages}
  alias MoodleNet.Meta.Pointers
  alias MoodleNet.Threads.{Comments, Thread}
  import Absinthe.Resolution.Helpers, only: [batch: 3]
  
  def thread(%{thread_id: id}, info), do: Threads.one(id: id, user: info.context.current_user)

  # edges
  
  def comments_edge(%Thread{id: id}, %{}=page_opts, %{context: %{current_user: user}}=info) do
    if GraphQL.in_list?(info) do
      with {:ok, page_opts} <- Batching.limit_page_opts(page_opts) do
        batch {__MODULE__, :batch_comments_edge, {page_opts,user}}, id, EdgesPages.getter(id)
      end
    else
      with {:ok, page_opts} <- Batching.full_page_opts(page_opts) do
        single_comments_edge(page_opts, user, id)
      end
    end
  end

  def single_comments_edge(page_opts, current_user, ids) do
    Comments.edges_page(
      &(&1.id),
      page_opts,
      [user: current_user, thread_id: ids],
      [order: :timeline_asc]
    )
  end

  def batch_comments_edge({page_opts, current_user}, ids) do
    {:ok, edges} = Comments.edges_pages(
      &(&1.thread_id),
      &(&1.id),
      page_opts,
      [user: current_user, thread_id: ids],
      [order: :timeline_asc],
      [group_count: :thread_id]
    )
    edges
  end

  def threads_edge(%{id: id}, %{}=page_opts, %{context: %{current_user: user}}=info) do
    if GraphQL.in_list?(info) do
      with {:ok, page_opts} <- Batching.limit_page_opts(page_opts) do
        batch {__MODULE__, :batch_threads_edge, {page_opts,user}}, id, EdgesPages.getter(id)
      end
    else
      with {:ok, page_opts} <- Batching.full_page_opts(page_opts) do
        single_threads_edge(page_opts, user, id)
      end
    end
  end

  def single_threads_edge(page_opts, current_user, ids) do
    Threads.edges_page(
      &(&1.id),
      page_opts,
      [user: current_user, context_id: ids],
      [join: :last_comment, order: :last_comment_desc, preload: :last_comment]
    )
  end

  def batch_threads_edge({page_opts, current_user}, ids) do
    {:ok, edges} = Threads.edges_pages(
      &(&1.context_id),
      &(&1.id),
      page_opts,
      [user: current_user, context_id: ids],
      [join: :last_comment, order: :last_comment_desc, preload: :last_comment],
      [group_count: :context_id]
    )
    edges
  end

  ## mutations

  def create_thread(%{context_id: context_id, comment: attrs}, info) do
    with {:ok, user} <- GraphQL.current_user(info) do
      Repo.transact_with(fn ->
        with {:ok, pointer} = Pointers.one(id: context_id),
             :ok <- validate_thread_context(pointer),
             context = Pointers.follow!(pointer),
             {:ok, thread} <- Threads.create(user, context, %{is_local: true}) do
          attrs = Map.put(attrs, :is_local, true)
          Comments.create(user, thread, attrs)
        end
      end)
    end
  end

  defp validate_thread_context(pointer) do
    if Pointers.table!(pointer).schema in valid_contexts() do
      :ok
    else
      GraphQL.not_permitted()
    end
  end

  defp valid_contexts() do
    Keyword.fetch!(Application.get_env(:moodle_net, Threads), :valid_contexts)
  end

  def last_activity_edge(_, _, _info), do: {:ok, DateTime.utc_now()}

end
