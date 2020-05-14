# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Blocks do
  alias Ecto.Changeset
  alias MoodleNet.{Common, Repo}
  alias MoodleNet.Blocks.{Block, Queries}
  alias MoodleNet.Users.User
  
  def one(filters), do: Repo.single(Queries.query(Block, filters))

  def many(filters), do: {:ok, Repo.all(Queries.query(Block, filters))}

  @spec find(User.t(), %{id: binary}) :: {:ok, Block.t()} | {:error, NotFoundError.t()}
  def find(%User{} = blocker, blocked) do
    one(deleted: false, creator: blocker.id, context: blocked.id)
  end

  @spec create(User.t(), any, map) :: {:ok, Block.t()} | {:error, Changeset.t()}
  def create(%User{} = blocker, blocked, fields) do
    Repo.insert(Block.create_changeset(blocker, blocked, fields))
  end

  @spec update(User.t(), Block.t(), map) :: {:ok, Block.t()} | {:error, Changeset.t()}
  def update(%User{}, %Block{} = block, fields) do
    Repo.update(Block.update_changeset(block, fields))
  end

  def update_by(%User{}=user, filters, updates) do
    Repo.update_all(Queries.query(Block, filters), set: updates)
  end

  @spec soft_delete(User.t(), Block.t()) :: {:ok, Block.t()} | {:error, Changeset.t()}
  def soft_delete(%User{}, %Block{} = block) do
    Common.soft_delete(block)
  end

  def soft_delete_by(%User{}=user, filters) do
    with {:ok, _} <-
      Repo.transact_with(fn ->
        {_, ids} = update_by(user, [{:deleted, false}, {:select, :id} | filters], deleted_at: DateTime.utc_now())
        :ok
      end), do: :ok
  end

end
