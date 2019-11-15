# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Comments do
  alias MoodleNet.{Common, Meta}
  alias MoodleNet.Comments.{Comment, Thread}
  alias MoodleNet.Common.{Revision, NotFoundError}
  alias MoodleNet.Users.User
  alias MoodleNet.Repo

  def fetch_thread(id), do: Repo.fetch(Thread, id)
  def fetch_comment(id), do: Repo.fetch(Comment, id)

  def create_thread(context, %User{} = creator, attrs) do
    Repo.transact_with fn ->
      context = Meta.find!(context.id)

      Meta.point_to!(Thread)
      |> Thread.create_changeset(context, creator, attrs)
      |> Repo.insert()
    end
  end

  def update_thread(%Thread{} = thread, attrs) do
    Repo.transact_with fn ->
      Repo.update(Thread.update_changeset(thread, attrs))
    end
  end

  def create_comment(%Thread{} = thread, %User{} = creator, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      Meta.point_to!(Comment)
      |> Comment.create_changeset(creator, thread, attrs)
      |> Repo.insert()
    end)
  end

  def update_comment(%Comment{} = comment, attrs) do
    Repo.update(Comment.update_changeset(comment, attrs))
  end
end
