# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common do

  alias MoodleNet.{Meta, Repo}
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Common.{DeletionError, Flag, Follow, Like}
  alias MoodleNet.Communities.Community
  import Ecto.Query
  alias MoodleNet.Common.Changeset

  ### pagination

  def paginate(query, opts) do
    offset = opts[:offset] || opts["offset"]
    limit = opts[:limit] || opts["limit"]

    query
    |> offset(^offset)
    |> limit(^limit)
  end

  ### liking

  ## TODO: schedule feed publishes

  @doc """
  NOTE: assumes liked participates in meta, otherwise gives constraint error changeset
  """
  def like(%Actor{}=liker, liked, fields) do
    Repo.transact_with fn ->
      pointer = Meta.find!(liked.id)

      Meta.point_to!(Like)
      |> Like.create_changeset(liker, pointer, fields)
      |> Repo.insert()
    end
  end

  def update_like(%Like{}=like, fields) do
    Like.update_changeset(like, fields)
    |> Repo.update()
  end

  @doc """
  Return a list of likes for an actor.
  """
  def likes_by(%Actor{}=actor), do: Repo.all(likes_by_query(actor))

  @doc """
  Return a list of likes for any object participating in the meta abstraction.
  """
  def likes_of(%{id: _id}=thing), do: Repo.all(likes_of_query(thing))

  defp likes_by_query(%Actor{id: id}) do
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

  def flag(%Actor{} = flagger, flagged, fields) do
    Repo.transact_with(fn ->
      pointer = Meta.find!(flagged.id)

      Meta.point_to!(Flag)
      |> Flag.create_changeset(flagger, pointer, fields)
      |> Repo.insert()
    end)
  end

  def flag(%Actor{} = flagger, flagged, community, fields) do
    Repo.transact_with(fn ->
      pointer = Meta.find!(flagged.id)

      Meta.point_to!(Flag)
      |> Flag.create_changeset(flagger, community, pointer, fields)
      |> Repo.insert()
    end)
  end

  def resolve_flag(%Flag{} = flag) do
    Repo.transact_with(fn ->
      soft_delete(flag)
    end)
  end

  @doc """
  Return a list of open flags for an actor.
  """
  def flags_by(%Actor{} = actor), do: Repo.all(flags_by_query(actor))

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

  defp flags_by_query(%Actor{id: id}) do
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

  @spec follow(Actor.t(), any, map) :: {:ok, Follow.t()} | {:error, Changeset.t()}
  def follow(%Actor{} = follower, followed, fields) do
    Repo.transact_with(fn ->
      pointer = Meta.find!(followed.id)

      follower
      |> Follow.create_changeset(pointer, fields)
      |> Repo.insert()
    end)
  end

  @spec update_follow(Follow.t(), map) :: {:ok, Follow.t()} | {:error, Changeset.t()}
  def update_follow(%Follow{} = follow, fields) do
    Repo.transact_with(fn ->
      follow
      |> Follow.update_changeset(fields)
      |> Repo.update()
    end)
  end

  @spec unfollow(Follow.t()) :: {:ok, Follow.t()} | {:error, Changeset.t()}
  def unfollow(%Follow{} = follow), do: soft_delete(follow)

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
