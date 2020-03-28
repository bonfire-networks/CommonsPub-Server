# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommentsResolver do

  alias MoodleNet.{GraphQL, Repo, Threads}
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Flags.Flag
  alias MoodleNet.GraphQL.Flow
  alias MoodleNet.Meta.Pointers
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Threads.{Comment, Comments, Thread}

  def comment(%{comment_id: id}, %{context: %{current_user: user}}) do
    Comments.one(id: id, user: user)
  end

  def comments_edge(%Thread{id: id}, %{}=page_opts, info) do
    opts = %{default_limit: 10}
    Flow.pages(__MODULE__, :fetch_comments_edge, page_opts, id, info, opts)
  end

  def fetch_comments_edge({page_opts, info}, ids) do
    user = GraphQL.current_user(info)
    {:ok, edges} = Comments.pages(
      &(&1.thread_id),
      &(&1.id),
      page_opts,
      [user: user, thread_id: ids],
      [order: :timeline_asc],
      [group_count: :thread_id]
    )
    edges
  end

  def fetch_comments_edge(page_opts, info, id) do
    user = GraphQL.current_user(info)
    Comments.page(
      &(&1.id),
      page_opts,
      [user: user, thread_id: id],
      [order: :timeline_asc]
    )
  end

  def in_reply_to_edge(%Comment{reply_to_id: nil}, _, _info), do: {:ok, nil}
  def in_reply_to_edge(%Comment{reply_to_id: id}, _, info) do
    Flow.fields(__MODULE__, :fetch_in_reply_to_edge, id, info)
  end

  def fetch_in_reply_to_edge(user, ids) do
    {:ok, fields} = Comments.fields(&(&1.id), id: ids, user: user)
    fields
  end

  def thread_edge(%Comment{thread: %Thread{}=thread}, _, _info), do: {:ok, thread}
  def thread_edge(%Comment{thread_id: id}, _, info) do
    Flow.fields(__MODULE__, :fetch_thread_edge, id, info)
  end

  def fetch_thread_edge(user, ids) do
    {:ok, fields} = Threads.fields(&(&1.id), id: ids, user: user)
    fields
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

  def last_activity_edge(_, _, _info) do
    {:ok, DateTime.utc_now()}
  end

end
