# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Comments do
  import Ecto.Query
  alias MoodleNet.{Common, Meta}
  alias MoodleNet.Comments.{Comment, Thread}
  alias MoodleNet.Common.{Revision, NotFoundError}
  alias MoodleNet.Users.User
  alias MoodleNet.Repo

  #
  # Threads
  #

  @spec fetch_thread(binary()) :: {:ok, Thread.t()} | {:error, NotFoundError.t()}
  def fetch_thread(id), do: Repo.single(fetch_thread_q(id))

  defp fetch_thread_q(id) do
    from(t in Thread,
      where: t.id == ^id,
      where: is_nil(t.hidden_at)
    )
  end

  @spec create_thread(context :: any, User.t(), map) ::
          {:ok, Thread.t()} | {:error, Changeset.t()}
  def create_thread(context, %User{} = creator, attrs) do
    Repo.transact_with(fn ->
      context = Meta.find!(context.id)

      Meta.point_to!(Thread)
      |> Thread.create_changeset(context, creator, attrs)
      |> Repo.insert()
    end)
  end

  @spec update_thread(Thread.t(), map) :: {:ok, Thread.t()} | {:error, Changeset.t()}
  def update_thread(%Thread{} = thread, attrs) do
    Repo.transact_with(fn ->
      Repo.update(Thread.update_changeset(thread, attrs))
    end)
  end

  @spec soft_delete_thread(Thread.t()) :: {:ok, Thread.t()} | {:error, Changeset.t()}
  def soft_delete_thread(%Thread{} = thread), do: Common.soft_delete(thread)

  #
  # Comments
  #

  @spec fetch_comment(binary()) :: {:ok, Comment.t()} | {:error, NotFoundError.t()}
  def fetch_comment(id), do: Repo.fetch(Comment, id)

  @spec create_comment(Thread.t(), User.t(), map) :: {:ok, Comment.t()} | {:error, Changeset.t()}
  def create_comment(%Thread{} = thread, %User{} = creator, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      Meta.point_to!(Comment)
      |> Comment.create_changeset(creator, thread, attrs)
      |> Repo.insert()
    end)
  end

  # TODO: don't allow replies when locked
  # def create_comment_reply() do
  # end

  @spec update_comment(Comment.t(), map) :: {:ok, Comment.t()} | {:error, Changeset.t()}
  def update_comment(%Comment{} = comment, attrs) do
    Repo.update(Comment.update_changeset(comment, attrs))
  end

  @spec soft_delete_comment(Comment.t()) :: {:ok, Comment.t()} | {:error, Changeset.t()}
  def soft_delete_comment(%Comment{} = comment), do: Common.soft_delete(comment)
end
