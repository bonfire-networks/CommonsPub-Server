# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Blocks do
  import ProtocolEx
  alias Ecto.Changeset
  alias MoodleNet.{Blocks, Common, Repo}
  alias MoodleNet.Blocks.{Block, Queries}
  alias MoodleNet.Meta.Pointable
  alias MoodleNet.Users.User
  
  @spec find(User.t(), %{id: binary}) :: {:ok, Block.t()} | {:error, NotFoundError.t()}
  def find(%User{} = blocker, blocked) do
    Repo.single(find_q(blocker.id, blocked.id))
  end

  defp find_q(blocker_id, blocked_id) do
    Queries.query(Block, [:deleted, creator_id: blocker_id, context_id: blocked_id])
  end

  @spec create(User.t(), any, map) :: {:ok, Block.t()} | {:error, Changeset.t()}
  def create(%User{} = blocker, blocked, fields) do
    Repo.insert(Block.create_changeset(blocker, blocked, fields))
  end

  @spec update(Block.t(), map) :: {:ok, Block.t()} | {:error, Changeset.t()}
  def update(%Block{} = block, fields) do
    Repo.update(Block.update_changeset(block, fields))
  end

  @spec delete(Block.t()) :: {:ok, Block.t()} | {:error, Changeset.t()}
  def delete(%Block{} = block), do: Common.soft_delete(block)

  defimpl_ex BlockPointable, Block, for: Pointable do
    def queries_module(_), do: Queries
  end

end
