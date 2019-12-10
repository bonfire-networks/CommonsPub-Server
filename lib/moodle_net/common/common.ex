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
    Feature,
    Flag,
    Follow,
    Like,
    Query,
    Tag
  }

  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Access.NotPermittedError
  alias MoodleNet.Common.{Changeset, NotFoundError}
  alias MoodleNet.Users.User
  alias MoodleNet.Workers.ActivityWorker
  import Ecto.Query

  ### pagination

  def paginate(query, opts), do: query

  defp cursor_or_id(%{cursor: cursor}), do: cursor
  defp cursor_or_id(%{id: id}), do: id
  
  def page_info(results, id \\ &cursor_or_id/1) when is_list(results) do
    case results do
      [] -> nil
      [x] -> %{start_cursor: id.(x), end_cursor: id.(x)}
      [x | xs] -> %{start_cursor: id.(x), end_cursor: id.(List.last(xs))}
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

  ### features

  def featured_collections() do
    featured_collections_q()
    |> Repo.all()
    |> Query.unroll()
  end

#todo counts
  def featured_communities() do
    featured_communities_q()
    |> Repo.all()
    |> Enum.map(fn {f,c,a} ->
      %{feature: f, community: c}
    end)
  end

  defp featured_collections_q() do
    from f in Feature,
      join: c in Collection,
      on: f.context_id == c.id,
      join: a in assoc(c, :actor),
      order_by: [desc: f.id],
      select: {f, c, a}
  end

  defp featured_communities_q() do
    from f in Feature,
      join: c in Collection,
      on: f.context_id == c.id,
      join: a in assoc(c, :actor),
      order_by: [desc: f.id],
      select: {f, c, a}
  end

  ### liking

  def fetch_like(id), do: Repo.single(fetch_like_q(id))

  defp fetch_like_q(id) do
    from l in Like,
      where: is_nil(l.deleted_at),
      where: not is_nil(l.published_at),
      where: l.id == ^id
  end

  def find_like(%User{} = liker, liked), do: Repo.single(find_like_q(liker.id, liked.id))

  defp find_like_q(liker_id, liked_id) do
    from(l in Like,
      where: l.creator_id == ^liker_id,
      where: l.context_id == ^liked_id,
      where: is_nil(l.deleted_at)
    )
  end

  def insert_like(%User{} = liker, liked, fields) do
    Repo.transact_with(fn ->
      pointer = Meta.find!(liked.id)
      Like.create_changeset(liker, pointer, fields)
      |> Repo.insert()
    end)
  end

  defp publish_like(%Like{} = like, verb) do
    MoodleNet.FeedPublisher.publish(%{
      "verb" => verb,
      "creator_id" => like.creator_id,
      "context_id" => like.id
    })
  end

  @doc """
  NOTE: assumes liked participates in meta, otherwise gives constraint error changeset
  """
  def like(%User{} = liker, liked, fields) do
    Repo.transact_with(fn ->
      case find_like(liker, liked) do
        {:ok, _} ->
          {:error, AlreadyLikedError.new("user")}

        _ ->
          with {:ok, like} <- insert_like(liker, liked, fields),
               {:ok, _} <- publish_like(like, "create") do
            {:ok, like}
          end
      end
    end)
  end

  def update_like(%Like{} = like, fields) do
    Like.update_changeset(like, fields)
    |> Repo.update()
  end

  @doc """
  Return a list of likes for a user.
  """
  def likes_by(%User{} = user), do: Repo.all(likes_by_query(user))

  @doc """
  Return a list of likes for any object participating in the meta abstraction.
  """
  def likes_of(%{id: _id} = thing), do: Repo.all(likes_of_query(thing))

  defp likes_by_query(%User{id: id}) do
    from(l in Like,
      where: is_nil(l.deleted_at),
      where: l.creator_id == ^id
    )
  end

  defp likes_of_query(%{id: id}) do
    from(l in Like,
      where: is_nil(l.deleted_at),
      where: l.context_id == ^id
    )
  end


  ## Flagging

  def fetch_flag(id), do: Repo.single(fetch_flag_q(id))

  defp fetch_flag_q(id) do
    from f in Flag,
      where: is_nil(f.deleted_at),
      where: f.id == ^id
  end

  def find_flag(%User{} = flagger, flagged) do
    Repo.single(find_flag_q(flagger.id, flagged.id))
  end

  defp find_flag_q(flagger_id, flagged_id) do
    from(f in Flag,
      where: f.creator_id == ^flagger_id,
      where: f.context_id == ^flagged_id,
      where: is_nil(f.deleted_at)
    )
  end

  def flag(%User{} = flagger, flagged, fields) do
    Repo.transact_with(fn ->
      case find_flag(flagger, flagged) do
        {:ok, _} -> {:error, AlreadyFlaggedError.new(flagged.id)}
        _ -> insert_flag(flagger, flagged, fields)
      end
    end)
  end

  def flag(%User{} = flagger, flagged, community, fields) do
    Repo.transact_with(fn ->
      case find_flag(flagger, flagged) do
        {:ok, _} -> {:error, AlreadyFlaggedError.new(flagged.id)}
        _ ->
          with {:ok, flag} <- insert_flag(flagger, flagged, community, fields),
               {:ok, _} <- publish_flag(flag, "create") do
            {:ok, flag}
          end
      end
    end)
  end

  defp insert_flag(flagger, flagged, fields) do
    Repo.transact_with(fn ->
      pointer = Meta.find!(flagged.id)

      Flag.create_changeset(flagger, pointer, fields)
      |> Repo.insert()
    end)
  end

  defp insert_flag(flagger, flagged, community, fields) do
    Repo.transact_with(fn ->
      pointer = Meta.find!(flagged.id)

      Flag.create_changeset(flagger, community, pointer, fields)
      |> Repo.insert()
    end)
  end

  defp publish_flag(%Flag{} = flag, verb) do
    MoodleNet.FeedPublisher.publish(%{
      "verb" => verb,
      "creator_id" => flag.creator_id,
      "context_id" => flag.id
    })
  end

  def resolve_flag(%Flag{} = flag) do
    Repo.transact_with(fn -> soft_delete(flag) end)
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
    query =
      from(f in Flag,
        where: is_nil(f.deleted_at),
        where: f.community_id == ^id
      )

    Repo.all(query)
  end

  defp flags_by_query(%User{id: id}) do
    from(f in Flag,
      where: is_nil(f.deleted_at),
      where: f.creator_id == ^id
    )
  end

  defp flags_of_query(%{id: id}) do
    from(f in Flag,
      where: is_nil(f.deleted_at),
      where: f.context_id == ^id
    )
  end

  ## Following

  def fetch_follow(id), do: Repo.single(fetch_follow_q(id))

  defp fetch_follow_q(id) do
    from f in Follow,
      where: is_nil(f.deleted_at),
      where: not is_nil(f.published_at),
      where: f.id == ^id
  end


  @spec list_follows(User.t()) :: [Follow.t()]
  def list_follows(%User{id: id}) do
    query =
      from(f in Follow,
        where: is_nil(f.deleted_at),
        where: f.creator_id == ^id
      )
    Repo.all(query)
  end

  def list_followed_communities(%User{id: id}) do
    query =
      from(f in Follow,
        join: c in Community,
	on: f.context_id == c.id,
        where: is_nil(f.deleted_at),
        where: f.creator_id == ^id,
	select: {f,c}
      )
    Repo.all(query)
  end

  def count_for_list_followed_communities(%User{id: id}) do
    query =
      from(f in Follow,
        join: c in Community,
	on: f.context_id == c.id,
        where: is_nil(f.deleted_at),
        where: f.creator_id == ^id,
	select: count(f)
      )
    Repo.one(query)
  end

  def list_followed_collections(%User{id: id}) do
    query =
      from(f in Follow,
        join: c in Collection,
	on: f.context_id == c.id,
        where: is_nil(f.deleted_at),
        where: f.creator_id == ^id,
	select: {f,c}
      )
    Repo.all(query)
  end

  def count_for_list_followed_collections(%User{id: id}) do
    query =
      from(f in Follow,
        join: c in Collection,
	on: f.context_id == c.id,
        where: is_nil(f.deleted_at),
        where: f.creator_id == ^id,
	select: count(f)
      )
    Repo.one(query)
  end

  @spec list_by_followed(%{id: binary}) :: [Follow.t()]
  def list_by_followed(%{id: id} = followed) do
    query =
      from(f in Follow,
        where: is_nil(f.deleted_at),
        where: f.context_id == ^id
      )

    Repo.all(query)
  end

  @spec find_follow(User.t(), %{id: binary}) :: {:ok, Follow.t()} | {:error, NotFoundError.t()}
  def find_follow(%User{} = follower, followed) do
    Repo.single(follow_q(follower.id, followed.id))
  end

  defp follow_q(follower_id, followed_id) do
    from(f in Follow,
      where: is_nil(f.deleted_at),
      where: f.creator_id == ^follower_id,
      where: f.context_id == ^followed_id
    )
  end

  @spec follow(User.t(), any, map) :: {:ok, Follow.t()} | {:error, Changeset.t()}
  def follow(%User{} = follower, followed, fields) do
    Repo.transact_with(fn ->
      case find_follow(follower, followed) do
        {:ok, _} ->
          {:error, AlreadyFollowingError.new("user")}

        _ ->
          with {:ok, follow} <- insert_follow(follower, followed, fields),
               {:ok, _} <- publish_follow(follow, "create") do
            {:ok, follow}
          end
      end
    end)
  end

  defp insert_follow(follower, followed, fields) do
    Repo.transact_with(fn ->
      pointer = Meta.find!(followed.id)

      Follow.create_changeset(follower, pointer, fields)
      |> Repo.insert()
    end)
  end

  defp publish_follow(%Follow{} = follow, verb) do
    MoodleNet.FeedPublisher.publish(%{
      "verb" => verb,
      "creator_id" => follow.creator_id,
      "context_id" => follow.id
    })
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
  def undo_follow(%Follow{} = follow) do
    Repo.transact_with(fn ->
      with {:ok, follow} <- soft_delete(follow),
           {:ok, _} <- publish_follow(follow, "delete") do
        {:ok, follow}
      end
    end)
  end

  ## Blocking
  @spec find_block(User.t(), %{id: binary}) :: {:ok, Block.t()} | {:error, NotFoundError.t()}
  def find_block(%User{} = blocker, blocked) do
    Repo.single(block_q(blocker.id, blocked.id))
  end

  defp block_q(blocker_id, blocked_id) do
    from(b in Block,
      where: is_nil(b.deleted_at),
      where: b.creator_id == ^blocker_id,
      where: b.context_id == ^blocked_id
    )
  end

  @spec block(User.t(), any, map) :: {:ok, Block.t()} | {:error, Changeset.t()}
  def block(%User{} = blocker, blocked, fields) do
    Repo.transact_with(fn ->
      pointer = Meta.find!(blocked.id)

      Block.create_changeset(blocker, pointer, fields)
      |> Repo.insert()
    end)
  end

  @spec update_block(Block.t(), map) :: {:ok, Block.t()} | {:error, Changeset.t()}
  def update_block(%Block{} = block, fields) do
    Repo.transact_with(fn ->
      block
      |> Block.update_changeset(fields)
      |> Repo.update()
    end)
  end

  @spec delete_block(Block.t()) :: {:ok, Block.t()} | {:error, Changeset.t()}
  def delete_block(%Block{} = block), do: soft_delete(block)

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
    )
    |> deletion_result()
  end

  @spec hard_delete!(any()) :: any()
  @doc "Deletes an entry from the database, or throws a DeletionError"
  def hard_delete!(it),
    do: deletion_result!(hard_delete(it))

  def deletion_result({:error, e}), do: {:error, DeletionError.new(e)}
  def deletion_result(other), do: other

  def deletion_result!({:ok, val}), do: val
  def deletion_result!({:error, e}), do: throw(e)
end
