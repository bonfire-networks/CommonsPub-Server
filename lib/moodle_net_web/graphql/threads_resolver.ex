# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.ThreadsResolver do

  alias MoodleNet.{GraphQL, Repo, Threads}
  alias MoodleNet.Batching.{EdgesPages}
  alias MoodleNet.Meta.Pointers
  alias MoodleNet.Threads.{Comments, Thread}
  import Absinthe.Resolution.Helpers, only: [batch: 3]
  
  def thread(%{thread_id: id}, info), do: Threads.one(id: id, user: info.context.current_user)

  # edges
  
  def comments_edge(%Thread{id: id}, _, info) do
    batch {__MODULE__, :batch_comments_edge, info.context.current_user}, id, EdgesPages.getter(id)
  end

  def batch_comments_edge(current_user, ids) do
    {:ok, edges} = Comments.edges_pages(
      &(&1.thread_id),
      &(&1.id),
      [user: current_user, thread_id: ids],
      [order: :timeline_asc],
      [group_count: :thread_id]
    )
    edges
  end

  def threads_edge(%{id: id}, _, %{context: %{current_user: user}}) do
    batch {__MODULE__, :batch_threads_edge, user}, id, EdgesPages.getter(id)
  end

  def batch_threads_edge(current_user, ids) do
    {:ok, edges} = Threads.edges_pages(
      &(&1.context_id),
      &(&1.id),
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
