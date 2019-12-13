# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommentsResolver do

  alias MoodleNet.{Comments, Fake, GraphQL, Repo}
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Comments.{Comment, Thread}
  alias MoodleNet.Communities.Community
  alias MoodleNet.Flags.Flag
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Users.User
  
  def comment(%{comment_id: id}, info), do: Comments.fetch_comment(id)

  def in_reply_to(%Comment{reply_to_id: id}, _, info), do: Comments.fetch_comment(id)

  def comments(%User{}=user, _, info) do
    comments = Comments.list_comments_for_user(user)
    count = Enum.count(comments)
    {:ok, Enum.edge_list(comments, count)}
  end
  def comments(%Thread{}=parent, _, info) do
    comments = Comments.list_comments_in_thread(parent)
    count = Enum.count(comments)
    {:ok, Enum.edge_list(comments, count)}
  end

  def thread(%{thread_id: id}, info), do: Comments.fetch_thread(id)
  def thread(%Comment{}=parent,_, info) do # on comment
    {:ok, Repo.preload(parent, :thread).thread}
  end

  def threads(%{id: context_id}=parent, _, info) do
    threads = Comments.list_threads_on(context_id)
    count = Enum.count(threads)
    {:ok, GraphQL.edge_list(threads, count)}
  end

  def create_thread(%{context_id: context_id, comment: attrs}, info) do
    with {:ok, user} <- GraphQL.current_user(info) do
      Repo.transact_with(fn ->
        with {:ok, pointer} = Meta.find(context_id),
             context = Meta.follow!(pointer),
             :ok <- validate_thread_context(context),
             {:ok, thread} <- Comments.create_thread(user, context, %{is_local: true}),
             attrs = Map.put(attrs, :is_local, true) do
          Comments.create_comment(user, thread, Map.put(attrs))
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
        with {:ok, thread} <- Comments.fetch_thread(thread_id),
             {:ok, parent} <- Comments.fetch_comment(reply_to),
             attrs = Map.put(attrs, :is_local, true) do
          Comments.create_comment_reply(user, thread, parent, attrs)
        end
      end)
    end
  end

  def update(%{comment_id: comment_id, comment: changes}, info) do
    with {:ok, user} <- GraphQL.current_user(info),
         {:ok, comment} <- Comments.fetch_comment(comment_id) do
      cond do
        user.is_local_admin ->
          Comments.update_comment(comment, changes)
        comment.creator_id == user.id ->
          Comments.update_comment(comment, changes)
        true -> GraphQL.not_permitted("update")
      end
    end
  end

  def last_activity(_, _, info) do
    {:ok, Fake.past_datetime()}
    |> GraphQL.response(info)
  end
end
