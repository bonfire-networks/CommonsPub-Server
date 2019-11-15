# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common do

  alias MoodleNet.{Meta, Repo}
  alias MoodleNet.Common.{
    AlreadyFlaggedError,
    AlreadyFollowingError,
    AlreadyLikedError,
    Block,
    DeletionError,
    Flag,
    Follow,
    Like,
    Tag,
  }
  alias MoodleNet.Communities.Community
  alias MoodleNet.Common.Changeset
  alias MoodleNet.Users.User
  import Ecto.Query

  ### pagination

  def paginate(query, opts), do: query

  def page_info(results) when is_list(results) do
    case results do
      [] -> %{start_cursor: "", end_cursor: ""}
      [x] -> %{start_cursor: x.id, end_cursor: x.id}
      [x | xs] -> %{start_cursor: x.id, end_cursor: List.last(xs).id}
    end
  end

  # @doc "Optionally paginates a query according to a user's request"
  # def paginate(query, opts) do
  # end

  # defp paginate_before(query, nil), do: {:ok, query}

  # defp paginate_before(query, offset)
  # when is_integer(offset) and offset >= 0, do: {:ok, offset(query, ^offset)}


  # defp paginate_before_q(query) do
  #   where(q, [
  # end

  # defp paginate_limit(query, nil), do: {:ok, query}

  # defp paginate_limit(query, limit)
  # when is_integer(limit) and limit >= 0 and limit <= 100,
  #   do: {:ok, limit(query, ^limit)}

  # defp paginate_limit(query, limit)

  ### liking

  def find_like(%User{}=liker, liked), do: Repo.single(find_like_q(liker.id, liked.id))

  defp find_like_q(liker_id, liked_id) do
    from l in Like,
      where: l.liker_id == ^liker_id,
      where: l.liked_id == ^liked_id,
      where: is_nil(l.deleted_at)
  end

  def insert_like(%User{}=liker, liked, fields) do
    Repo.transact_with fn ->
      pointer = Meta.find!(liked.id)

      Meta.point_to!(Like)
      |> Like.create_changeset(liker, pointer, fields)
      |> Repo.insert()
    end
  end

  @doc """
  NOTE: assumes liked participates in meta, otherwise gives constraint error changeset
  """
  def like(%User{}=liker, liked, fields) do
    Repo.transact_with fn ->
      case find_like(liker, liked) do
        {:ok, _} -> {:error, AlreadyLikedError.new("user")}
        _ -> insert_like(liker, liked, fields)
      end
    end
  end

  def update_like(%Like{}=like, fields) do
    Like.update_changeset(like, fields)
    |> Repo.update()
  end

  @doc """
  Return a list of likes for a user.
  """
  def likes_by(%User{}=user), do: Repo.all(likes_by_query(user))

  @doc """
  Return a list of likes for any object participating in the meta abstraction.
  """
  def likes_of(%{id: _id}=thing), do: Repo.all(likes_of_query(thing))

  defp likes_by_query(%User{id: id}) do
    from l in Like,
      where: is_nil(l.deleted_at),
      where: l.liker_id == ^id
  end

  defp likes_of_query(%{id: id}) do
    from l in Like,
      where: is_nil(l.deleted_at),
      where: l.liked_id == ^id
  end

  ## Flagging

  def find_flag(%User{} = flagger, flagged) do
    Repo.single(find_flag_q(flagger.id, flagged.id))
  end

  defp find_flag_q(flagger_id, flagged_id) do
    from f in Flag,
      where: f.flagger_id == ^flagger_id,
      where: f.flagged_id == ^flagged_id,
      where: is_nil(f.deleted_at)
  end

  def flag(%User{} = flagger, flagged, fields) do
    Repo.transact_with fn ->
      case find_flag(flagger, flagged) do
        {:ok, _} -> {:error, AlreadyFlaggedError.new(flagged.id)}
        _ -> insert_flag(flagger, flagged, fields)
      end
    end
  end

  def flag(%User{} = flagger, flagged, community, fields) do
    Repo.transact_with fn ->
      case find_flag(flagger, flagged) do
        {:ok, _} -> {:error, AlreadyFlaggedError.new(flagged.id)}
        _ -> insert_flag(flagger, flagged, community, fields)
      end
    end
  end

  defp insert_flag(flagger, flagged, fields) do
    Repo.transact_with fn ->
      pointer = Meta.find!(flagged.id)
      Meta.point_to!(Flag)
      |> Flag.create_changeset(flagger, pointer, fields)
      |> Repo.insert()
    end
  end

  defp insert_flag(flagger, flagged, community, fields) do
    Repo.transact_with fn ->
      pointer = Meta.find!(flagged.id)
      Meta.point_to!(Flag)
      |> Flag.create_changeset(flagger, community, pointer, fields)
      |> Repo.insert()
    end
  end

  def resolve_flag(%Flag{} = flag) do
    Repo.transact_with fn -> soft_delete(flag) end
  end

  @doc """
  Return a list of open flags for an user.
  """
  def flags_by(%User{} = user), do: Repo.all(flags_by_query(user))

  @doc """
  Return a list of open flags for any object participating in the meta abstraction.
  """
  def flags_of(%{id: _id} = thing), do: Repo.all(flags_of_query(thing))

  @doc """
  Return open flags for a community.
  """
  def flags_of_community(%Community{id: id}) do
    query = from f in Flag,
      where: is_nil(f.deleted_at),
      where: f.community_id == ^id

    Repo.all(query)
  end

  defp flags_by_query(%User{id: id}) do
    from f in Flag,
      where: is_nil(f.deleted_at),
      where: f.flagger_id == ^id
  end

  defp flags_of_query(%{id: id}) do
    from f in Flag,
      where: is_nil(f.deleted_at),
      where: f.flagged_id == ^id
  end

  ## Following

  defp follow_q(follower_id, followed_id) do
    from f in Follow,
      where: is_nil(f.deleted_at),
      where: f.follower_id == ^follower_id,
      where: f.followed_id == ^followed_id
  end

  def find_follow(%User{} = follower, followed) do
    Repo.single(follow_q(follower.id, followed.id))
  end

  @spec follow(User.t, any, map) :: {:ok, Follow.t()} | {:error, Changeset.t()}
  def follow(%User{} = follower, followed, fields) do
    Repo.transact_with fn ->
      case find_follow(follower, followed) do
  	{:ok, _} -> {:error, AlreadyFollowingError.new("user")}
  	_ -> insert_follow(follower, followed, fields)
      end
    end
  end

  defp insert_follow(follower, followed, fields) do
    Repo.transact_with fn ->
      pointer = Meta.find!(followed.id)
      Meta.point_to!(Follow)
      |> Follow.create_changeset(follower, pointer, fields)
      |> Repo.insert()
    end
  end

  @spec update_follow(Follow.t(), map) :: {:ok, Follow.t()} | {:error, Changeset.t()}
  def update_follow(%Follow{} = follow, fields) do
    Repo.transact_with(fn ->
      follow
      |> Follow.update_changeset(fields)
      |> Repo.update()
    end)
  end

  @spec undo_follow(Follow.t()) :: {:ok, Follow.t()} | {:error, Changeset.t()}
  def undo_follow(%Follow{} = follow), do: soft_delete(follow)

  ## Blocking

  # @spec block(User.t(), any, map) :: {:ok, Block.t()} | {:error, Changeset.t()}
  # def block(%User{} = blocker, blocked, fields) do
  #   Repo.transact_with(fn ->
  #     pointer = Meta.find!(blocked.id)
  # 
  #     Meta.point_to!(Block)
  #     |> Block.create_changeset(blocker, pointer, fields)
  #     |> Repo.insert()
  #   end)
  # end

  # @spec update_block(Block.t(), map) :: {:ok, Block.t()} | {:error, Changeset.t()}
  # def update_block(%Block{} = block, fields) do
  #   Repo.transact_with(fn ->
  #     block
  #     |> Block.update_changeset(fields)
  #     |> Repo.update()
  #   end)
  # end

  # @spec delete_block(Block.t()) :: {:ok, Block.t} | {:error, Changeset.t()}
  # def delete_block(%Block{} = block), do: soft_delete(block)

  ## Tagging

  # @spec tag(User.t, any, map) :: {:ok, Tag.t} | {:error, Changeset.t()}
  # def tag(%User{} = tagger, tagged, fields) do
  #   Repo.transact_with(fn ->
  #     pointer = Meta.find!(tagged.id)

  #     tagger
  #     |> Tag.create_changeset(pointer, fields)
  #     |> Repo.insert()
  #   end)
  # end

  # @spec update_tag(Tag.t(), map) :: {:ok, Tag.t()} | {:error, Changeset.t()}
  # def update_tag(%Tag{} = tag, fields) do
  #   Repo.transact_with(fn ->
  #     tag
  #     |> Tag.update_changeset(fields)
  #     |> Repo.update()
  #   end)
  # end

  # @spec untag(Tag.t()) :: {:ok, Tag.t()} | {:error, Changeset.t()}
  # def untag(%Tag{} = tag), do: soft_delete(tag)

  ## Deletion

  @spec soft_delete(any()) :: {:ok, any()} | {:error, DeletionError.t()}
  @doc "Marks an entry as deleted in the database"
  def soft_delete(it), do: deletion_result(do_soft_delete(it))

  @spec soft_delete!(any()) :: any()
  @doc "Marks an entry as deleted in the database or throws a DeletionError"
  def soft_delete!(it), do: deletion_result!(do_soft_delete(it))

  defp do_soft_delete(it), do: Repo.update(Changeset.soft_delete_changeset(it))

  @spec hard_delete(any()) :: {:ok, any()} | {:error, DeletionError.t()}
  @doc "Deletes an entry from the database"
  def hard_delete(it) do
    it
    |> Repo.delete(
      stale_error_field: :id,
      stale_error_message: "has already been deleted"
    ) |> deletion_result()
  end

  @spec hard_delete!(any()) :: any()
  @doc "Deletes an entry from the database, or throws a DeletionError"
  def hard_delete!(it),
    do: deletion_result!(hard_delete(it))

  def deletion_result({:error, e}), do: {:error, DeletionError.new(e)}
  def deletion_result(other), do: other

  def deletion_result!({:ok, val}), do: val
  def deletion_result!({:error, e}), do: throw e

end
