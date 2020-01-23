# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommentsResolver do

  alias MoodleNet.{GraphQL, Repo, Threads}
  alias MoodleNet.Batching.{Edges, EdgesPages}
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Flags.Flag
  alias MoodleNet.Meta.Pointers
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Threads.{Comment, Comments, Thread}
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  def comment(%{comment_id: id}, %{context: %{current_user: user}}) do
    Comments.one(id: id, user: user)
  end

  def in_reply_to_edge(%Comment{reply_to_id: nil}, _, _info), do: {:ok, nil}
  def in_reply_to_edge(%Comment{reply_to_id: id}, _, %{context: %{current_user: user}}) do
    batch {__MODULE__, :batch_in_reply_to_edge, user}, id, Edges.getter(id)
  end

  def batch_in_reply_to_edge(user, ids) do
    {:ok, edges} = Comments.edges(&(&1.id), id: ids, user: user)
    edges
  end

  def thread_edge(%Comment{thread: %Thread{}=thread}, _, _info), do: {:ok, thread}
  def thread_edge(%Comment{thread_id: id}, _, %{context: %{current_user: user}}) do
    batch {__MODULE__, :batch_thread_edge, user}, id, Edges.getter(id)
  end

  def batch_thread_edge(user, ids) do
    {:ok, edges} = Threads.edges(&(&1.id), id: ids, user: user)
    edges
  end

  def threads_edge(%{id: id}, _, %{context: %{current_user: user}}) do
    batch {__MODULE__, :batch_threads_edge, user}, id, EdgesPages.getter(id)
  end

  def batch_threads_edge(user, ids) do
    {:ok, edges} = Threads.edges_pages(
      &(&1.context_id),
      &(&1.id),
      [context_id: ids, user: user],
      [join: :last_comment, order: :last_comment_desc],
      [group_count: :context_id]
    )
    edges
  end

  ## mutations

  def create_thread(%{context_id: context_id, comment: attrs}, info) do
    with {:ok, user} <- GraphQL.current_user(info) do
      Repo.transact_with(fn ->
        with {:ok, pointer} <- Pointers.one(id: context_id),
             context = Pointers.follow!(pointer),
             :ok <- validate_thread_context(context),
             {:ok, thread} <- Threads.create(user, context, %{is_local: true}) do
          attrs = Map.put(attrs, :is_local, true)
          Comments.create(user, thread, attrs)
        end
      end)
    end
  end

  defp validate_thread_context(%Collection{}), do: :ok
  defp validate_thread_context(%Community{}), do: :ok
  defp validate_thread_context(%Flag{}), do: :ok
  defp validate_thread_context(%Resource{}), do: :ok
  defp validate_thread_context(_), do: GraphQL.not_permitted("create")

  def create_reply(%{thread_id: thread_id, in_reply_to_id: reply_to, comment: attrs}, info) do
    with {:ok, user} <- GraphQL.current_user(info) do
      Repo.transact_with(fn ->
        with {:ok, thread} <- Threads.one([:hidden, :deleted, :private, id: thread_id]),
             {:ok, parent} <- Comments.one([:hidden, :deleted, :private, id: reply_to]),
             attrs = Map.put(attrs, :is_local, true) do
          Comments.create_reply(user, thread, parent, attrs)
        end
      end)
    end
  end

  def update(%{comment_id: comment_id, comment: changes}, info) do
    with {:ok, user} <- GraphQL.current_user(info),
         {:ok, comment} <- Comments.one(id: comment_id) do
      cond do
        user.is_local_admin ->
          Comments.update(comment, changes)
        comment.creator_id == user.id ->
          Comments.update(comment, changes)
        true -> GraphQL.not_permitted("update")
      end
    end
  end

  def last_activity_edge(_, _, info) do
    {:ok, DateTime.utc_now()}
  end
end
