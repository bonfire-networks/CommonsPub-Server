defmodule MoodleNet.Blocks do
  alias Ecto.Changeset
  alias MoodleNet.{Activities, Common, Repo}
  alias MoodleNet.Blocks.{AlreadyBlockedError, Block, NotBlockableError}
  alias MoodleNet.Users.User
  
  import Ecto.Query

  @spec find(User.t(), %{id: binary}) :: {:ok, Block.t()} | {:error, NotFoundError.t()}
  def find(%User{} = blocker, blocked) do
    Repo.single(find_q(blocker.id, blocked.id))
  end

  defp find_q(blocker_id, blocked_id) do
    from(b in Block,
      where: is_nil(b.deleted_at),
      where: b.creator_id == ^blocker_id,
      where: b.context_id == ^blocked_id
    )
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

end
