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
    Thread
  }
  alias MoodleNet.Common.{Revision, NotFoundError}
  alias MoodleNet.Repo

  def fetch_thread(id), do: Repo.fetch(Thread, id)
  def fetch_comment(id), do: Repo.fetch(Comment, id)

  def create_thread(parent, attrs) do
    Repo.transact_with(fn ->
      pointer = Meta.find!(parent.id)
      Repo.insert(Thread.create_changeset(pointer, attrs))
    end)
  end

  def update_thread(thread, attrs) do
    Repo.transact_with(fn ->
      Repo.update(Thread.update_changeset(thread, attrs))
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
end
