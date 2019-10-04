# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Comments do
  alias MoodleNet.{Common, Meta}
  alias MoodleNet.Comments.{
    Comment,
    CommentRevision,
    CommentLatestRevision,
    CommentFlag,
    CommentLike,
    Thread
  }
  alias MoodleNet.Common.{Revision, NotFoundError}
  alias MoodleNet.Repo

  def fetch_thread(id), do: Repo.fetch(Thread, id)
  def fetch_comment(id), do: Repo.fetch(Comment, id)

  # TODO: extract parent pointer
  def create_thread(parent, attrs) do
    Repo.transact_with(fn ->
      Repo.insert(Thread.create_changeset(parent, attrs))
    end)
  end

  def update_thread(parent, attrs) do
    Repo.transact_with(fn ->
      Repo.update(Thread.update_changeset(parent, attrs))
    end)
  end

  def create_comment(thread, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      pointer = Meta.point_to!(Comment)

      changeset = Comment.create_changeset(pointer, thread, attrs)
      with {:ok, comment} <- Repo.insert(changeset),
           {:ok, revision} <- Revision.insert(CommentRevision, comment, attrs) do
        latest_revision = CommentLatestRevision.forge(revision)
        {:ok, %Comment{comment | latest_revision: latest_revision, current: revision}}
      end
    end)
  end

  def update_comment(%Comment{} = comment, attrs) do
    Repo.transact_with(fn ->
      with {:ok, comment} <- Repo.update(Comment.update_changeset(comment, attrs)),
           {:ok, revision} <- Revision.insert(CommentRevision, comment, attrs) do
        latest_revision = CommentLatestRevision.forge(revision)
        {:ok, %Comment{comment | latest_revision: latest_revision, current: revision}}
      end
    end)
  end

  @doc """
  Likes a comment with a given reason
  {:ok, CommentLike} | {:error, reason}
  """
  def like(actor, comment),
    do: Common.like(CommentLike, :like_comment?, actor, comment)

  @doc """
  Undoes a previous like
  {:ok, CommentLike} | {:error, term()}
  """
  def undo_like(actor, comment), do: Common.undo_like(CommentLike, actor, comment)

  @doc """
  Lists all CommentLike matching the provided optional filters.
  Filters:
    :open :: boolean
  """
  def all_likes(actor, filters \\ %{}),
    do: Common.likes(CommentLike, :list_comment_likes?, actor, filters)



  ###

  @doc """
  Flags a comment with a given reason
  {:ok, CommentFlag} | {:error, reason}
  """
  def flag(actor, comment, attrs=%{reason: _}),
    do: Common.flag(CommentFlag, :flag_comment?, actor, comment, attrs)

  @doc """
  Undoes a previous flag
  {:ok, CommentFlag} | {:error, term()}
  """
  def undo_flag(actor, comment), do: Common.undo_flag(CommentFlag, actor, comment)

  @doc """
  Lists all CommentFlag matching the provided optional filters.
  Filters:
    :open :: boolean
  """
  def all_flags(actor, filters \\ %{}),
    do: Common.flags(CommentFlag, :list_comment_flags?, actor, filters)

end
