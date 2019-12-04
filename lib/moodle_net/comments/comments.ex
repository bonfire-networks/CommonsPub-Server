# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Comments do
  import Ecto.Query
  alias MoodleNet.{Common, Meta, Users, Repo}
  alias MoodleNet.Access.NotPermittedError
  alias MoodleNet.Comments.{Comment, Thread}
  alias MoodleNet.Common.{NotFoundError, Query}
  alias MoodleNet.Users.User
  alias MoodleNet.Workers.ActivityWorker
  alias Ecto.Association.NotLoaded

  #
  # Threads
  #

  @doc """
  Return a list of all unhidden threads, along with their follower count.
  """
  @spec list_threads() :: [Thread.t()]
  def list_threads do
    Enum.map(Repo.all(list_threads_q()), fn {thread, count} ->
      %Thread{thread | follower_count: count}
    end)
  end

  @doc """
  Return a list of all thread, regardless of hidden status.
  """
  @spec list_threads_private() :: [Thread.t()]
  def list_threads_private do
    Enum.map(Repo.all(list_threads_private_q()), fn {thread, count} ->
      %Thread{thread | follower_count: count}
    end)
  end

  def list_threads_private_q do
    Thread
    |> Query.order_by_recently_updated()
    |> follower_count_q()
  end

  defp list_threads_q do
    list_threads_private_q()
    |> only_unhidden_threads_q()
  end

  defp only_unhidden_threads_q(query) do
    from(q in query,
      where: is_nil(q.hidden_at),
      where: is_nil(q.deleted_at)
    )
  end

  defp follower_count_q(query) do
    from(q in query,
      left_join: fc in assoc(q, :follower_count),
      select: {q, fc},
      limit: 100,
      order_by: [desc: fc.count]
    )
  end

  @doc """
  Fetch an unhidden thread by ID.
  """
  @spec fetch_thread(binary()) :: {:ok, Thread.t()} | {:error, NotFoundError.t()}
  def fetch_thread(id), do: Repo.single(fetch_thread_q(id))

  defp fetch_thread_q(id) do
    from(t in Thread,
      where: t.id == ^id,
      where: is_nil(t.hidden_at),
      where: is_nil(t.deleted_at)
    )
  end

  @doc """
  Fetch a thread by ID, regardless of its hidden status.
  """
  @spec fetch_thread_private(binary()) :: {:ok, Thread.t()} | {:error, NotFoundError.t()}
  def fetch_thread_private(id), do: Repo.fetch(Thread, id)

  @doc """
  Fetch the creator of a thread.
  """
  @spec fetch_thread_creator(Thread.t()) :: {:ok, User.t()} | {:error, NotFoundError.t()}
  def fetch_thread_creator(%Thread{creator_id: id, creator: %NotLoaded{}}), do: Users.fetch(id)
  def fetch_thread_creator(%Thread{creator: creator}), do: {:ok, creator}

  @doc """
  Fetch the context of a thread, using its original type.
  """
  @spec fetch_thread_context(Thread.t()) :: {:ok, any} | {:error, NotFoundError.t()}
  def fetch_thread_context(%Thread{context_id: id, context: %NotLoaded{}}) do
    with {:ok, context} <- Meta.find(id) do
      Meta.follow(context)
    end
  end

  def fetch_thread_context(%Thread{context: context}), do: Meta.follow(context)

  @doc """
  Create a new thread for any context that participates in the meta abstraction.
  """
  @spec create_thread(context :: any, User.t(), map) ::
          {:ok, Thread.t()} | {:error, Changeset.t()}
  def create_thread(context, %User{} = creator, attrs) do
    Repo.transact_with(fn ->
      with {:ok, thread} <- insert_thread(context, creator, attrs),
           {:ok, _} <- publish_thread(thread, "create") do
        {:ok, thread}
      end
    end)
  end

  defp insert_thread(context, creator, attrs) do
    context = Meta.find!(context.id)

    Thread.create_changeset(context, creator, attrs)
    |> Repo.insert()
  end

  @doc """
  Update the attributes of a thread.
  """
  @spec update_thread(Thread.t(), map) :: {:ok, Thread.t()} | {:error, Changeset.t()}
  def update_thread(%Thread{} = thread, attrs) do
    Repo.transact_with(fn ->
      Repo.update(Thread.update_changeset(thread, attrs))
    end)
  end

  @spec soft_delete_thread(Thread.t()) :: {:ok, Thread.t()} | {:error, Changeset.t()}
  def soft_delete_thread(%Thread{} = thread) do
    Repo.transact_with(fn ->
      with {:ok, thread} <- Common.soft_delete(thread),
           {:ok, _} <- publish_thread(thread, "delete") do
        {:ok, thread}
      end
    end)
  end

  defp publish_thread(%Thread{} = thread, verb) do
    MoodleNet.FeedPublisher.publish(%{
      "verb" => verb,
      "user_id" => thread.creator_id,
      "context_id" => thread.id,
    })
  end

  #
  # Comments
  #

  @doc """
  Return a list of public, non-deleted, unhidden comments contained in a  thread.

  Ignores all comments if the parent thread has been deleted.
  """
  @spec list_comments_in_thread(Thread.t()) :: [Comment.t()]
  def list_comments_in_thread(%Thread{} = thread),
    do: Repo.all(list_comments_in_thread_q(thread.id))

  defp list_comments_in_thread_q(thread_id) do
    from(c in Comment,
      join: t in Thread,
      on: c.thread_id == t.id,
      where: t.id == ^thread_id,
      where: not is_nil(c.published_at),
      where: is_nil(c.hidden_at),
      where: is_nil(c.deleted_at),
      # allow for threads that are hidden because they can't be fetched unless
      # you use fetch_thread_private
      where: is_nil(t.deleted_at)
    )
  end

  @doc """
  Return all public, non-deleted, unhidden comments for a user.

  Will fetch comments regardless of whether the user has been deleted.
  """
  @spec list_comments_for_user(User.t()) :: [Comment.t()]
  def list_comments_for_user(%User{} = user),
    do: Repo.all(list_comments_for_user_q(user.id))

  defp list_comments_for_user_q(user_id) do
    from(c in Comment,
      join: u in User,
      on: c.creator_id == u.id,
      where: u.id == ^user_id,
      where: not is_nil(c.published_at),
      where: is_nil(c.hidden_at),
      where: is_nil(c.deleted_at)
    )
  end

  @doc """
  Fetch a public, non-deleted, unhidden comment by ID.

  Will ignore comments where the parent thread have been hidden or deleted.
  """
  @spec fetch_comment(binary()) :: {:ok, Comment.t()} | {:error, NotFoundError.t()}
  def fetch_comment(id), do: Repo.single(fetch_comment_q(id))

  defp fetch_comment_q(id) do
    from(c in Comment,
      join: t in Thread,
      on: c.thread_id == t.id,
      where: c.id == ^id,
      where: not is_nil(c.published_at),
      where: is_nil(c.hidden_at),
      where: is_nil(c.deleted_at),
      where: is_nil(t.hidden_at),
      where: is_nil(t.deleted_at)
    )
  end

  @spec fetch_comment_thread(Comment.t()) :: {:ok, User.t()} | {:error, NotFoundError.t()}
  def fetch_comment_creator(%Comment{creator_id: id, creator: %NotLoaded{}}), do: Users.fetch(id)
  def fetch_comment_creator(%Comment{creator: creator}), do: {:ok, creator}

  @spec fetch_comment_thread(Comment.t()) :: {:ok, Thread.t()} | {:error, NotFoundError.t()}
  def fetch_comment_thread(%Comment{thread_id: id, thread: %NotLoaded{}}), do: fetch_thread(id)
  def fetch_comment_thread(%Comment{thread: thread}), do: {:ok, thread}

  @spec fetch_comment_thread(Comment.t()) :: {:ok, Thread.t()} | {:error, NotFoundError.t()}
  def fetch_comment_reply_to(%Comment{reply_to_id: nil} = comment), do: {:error, NotFoundError.new()}
  def fetch_comment_reply_to(%Comment{reply_to_id: id, reply_to: %NotLoaded{}}), do: fetch_comment(id)
  def fetch_comment_reply_to(%Comment{reply_to: reply_to}), do: {:ok, reply_to}

  @spec create_comment(Thread.t(), User.t(), map) :: {:ok, Comment.t()} | {:error, Changeset.t()}
  def create_comment(%Thread{} = thread, %User{} = creator, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      with {:ok, comment} <- insert_comment(thread, creator, attrs),
           {:ok, _} <- publish_comment(comment, "create") do
        {:ok, comment}
      end
    end)
  end

  @doc """
  Create a comment in reply to another comment.

  Will fail with `NotPermittedError` if the parent thread is locked.
  """
  @spec create_comment_reply(Thread.t(), User.t(), Comment.t(), map) ::
          {:ok, Comment.t()} | {:error, Changeset.t()} | {:error, NotPermittedError.t()}
  def create_comment_reply(%Thread{} = thread, %User{} = creator, %Comment{} = reply_to, attrs) do
    # FIXME: check that the thread you're replying to is the same one
    if thread.locked_at do
      {:error, NotPermittedError.new("create")}
    else
      Repo.transact_with(fn ->
        with {:ok, comment} <- insert_comment(thread, creator, reply_to, attrs),
             {:ok, _} <- publish_comment(comment, "create") do
          {:ok, comment}
        end
      end)
    end
  end

  defp insert_comment(thread, creator, attrs) do
    Comment.create_changeset(creator, thread, attrs)
    |> Repo.insert()
  end

  defp insert_comment(thread, creator, reply_to, attrs) do
    Comment.create_changeset(creator, thread, attrs)
    |> Comment.reply_to_changeset(reply_to)
    |> Repo.insert()
  end

  @spec update_comment(Comment.t(), map) :: {:ok, Comment.t()} | {:error, Changeset.t()}
  def update_comment(%Comment{} = comment, attrs) do
    Repo.update(Comment.update_changeset(comment, attrs))
  end

  @spec soft_delete_comment(Comment.t()) :: {:ok, Comment.t()} | {:error, Changeset.t()}
  def soft_delete_comment(%Comment{} = comment) do
    Repo.transact_with(fn ->
      with {:ok, comment} <- Common.soft_delete(comment),
           {:ok, _} <- publish_comment(comment, "delete") do
        {:ok, comment}
      end
    end)
  end

  defp publish_comment(%Comment{} = comment, verb) do
    MoodleNet.FeedPublisher.publish(%{
      "verb" => verb,
      "context_id" => comment.id,
      "user_id" => comment.creator_id,
    })
  end
end
