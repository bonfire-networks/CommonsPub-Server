# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Follows do
  alias MoodleNet.{Activities, Common, Feeds, Meta, Repo}
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Common.NotFoundError
  alias MoodleNet.Follows.{
    AlreadyFollowingError,
    Follow,
    NotFollowableError,
  }
  alias MoodleNet.Users.User
  alias Ecto.Changeset
  import Ecto.Query

  def fetch(id), do: Repo.single(fetch_q(id))

  defp fetch_q(id) do
    from f in Follow,
      where: is_nil(f.deleted_at),
      where: not is_nil(f.published_at),
      where: f.id == ^id
  end

  @spec list_by(User.t()) :: [Follow.t()]
  def list_by(%User{id: id}) do
    query =
      from(f in Follow,
        where: is_nil(f.deleted_at),
        where: f.creator_id == ^id
      )
    Repo.all(query)
  end

  def list_communities(%User{id: id}) do
    from(f in Follow,
      join: c in Community,
      on: f.context_id == c.id,
      join: a in assoc(c, :actor),
      where: is_nil(f.deleted_at),
      where: f.creator_id == ^id,
      select: {f,c,a}
    )
    |> Repo.all()
    |> Enum.map(fn {f, c, a} -> %{f | ctx: %{ c | actor: a }} end)
  end

  def count_for_list_communities(%User{id: id}) do
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

  def list_collections(%User{id: id}) do
    from(f in Follow,
      join: c in Collection,
      on: f.context_id == c.id,
      join: a in assoc(c, :actor),
      where: is_nil(f.deleted_at),
      where: f.creator_id == ^id,
      select: {f,c,a}
    )
    |> Repo.all()
    |> Enum.map(fn {f, c, a} -> %{f | ctx: %{c | actor: a}} end)
  end

  def count_for_list_collections(%User{id: id}) do
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

  @spec list_of(%{id: binary}) :: [Follow.t()]
  def list_of(%{id: id} = followed) do
    query =
      from(f in Follow,
        join: c in assoc(f, :creator),
        where: is_nil(f.deleted_at),
        where: f.context_id == ^id,
        preload: [creator: c]
      )

    Repo.all(query)
  end

  @spec find(User.t(), %{id: binary}) :: {:ok, Follow.t()} | {:error, NotFoundError.t()}
  def find(%User{} = follower, followed) do
    Repo.single(find_q(follower.id, followed.id))
  end

  defp find_q(follower_id, followed_id) do
    from(f in Follow,
      where: is_nil(f.deleted_at),
      where: f.creator_id == ^follower_id,
      where: f.context_id == ^followed_id
    )
  end

  @spec create(User.t(), any, map) :: {:ok, Follow.t()} | {:error, Changeset.t()}
  def create(%User{} = follower, %{outbox_id: outbox_id}=followed, fields) do
    Repo.transact_with(fn ->
      case find(follower, followed) do
        {:ok, _} ->
          {:error, AlreadyFollowingError.new("user")}

        _ ->
          sub_attrs = %{is_active: true}
          with {:ok, _sub} <- Feeds.create_sub(follower, outbox_id, sub_attrs),
               {:ok, follow} <- insert(follower, followed, fields),
               act_attrs = %{verb: "create", is_local: follow.is_local},
               {:ok, activity} <- Activities.create(follower, follow, act_attrs),
               :ok <- publish(follow, follower, followed, activity, :create) do
            {:ok, %{follow | ctx: followed}}
          end
      end
    end)
  end

  defp insert(follower, followed, fields) do
    Repo.insert(Follow.create_changeset(follower, followed, fields))
  end

  defp publish(%Follow{} = follow, creator, followed, activity, :create) do
    # Feeds.publish_to_feeds([creator.outbox_id, followed
    :ok
  end
  defp publish(%Follow{} = follow, activity, :update) do
    # Feeds.publish_to_feeds([creator.outbox_id, followed
    :ok
  end
  defp publish(%Follow{} = follow, activity, :delete) do
    # Feeds.publish_to_feeds([creator.outbox_id, followed
    :ok
  end

  @spec update(Follow.t(), map) :: {:ok, Follow.t()} | {:error, Changeset.t()}
  def update(%Follow{} = follow, fields) do
    Repo.transact_with(fn ->
      follow
      |> Follow.update_changeset(fields)
      |> Repo.update()
    end)
  end

  @spec undo(Follow.t()) :: {:ok, Follow.t()} | {:error, Changeset.t()}
  def undo(%Follow{} = follow) do
    Repo.transact_with(fn ->
      case follow.is_local do
        true ->
          follow = Repo.preload(follow, [:creator, :context])
          with {:ok, _} <- unsubscribe(follow),
               {:ok, follow} <- Common.soft_delete(follow),
               act_attrs = %{verb: "delete", is_local: follow.is_local},
               {:ok, activity} <- Activities.create(follow.creator, follow, act_attrs),
               :ok <- publish(follow, activity, :delete) do
            {:ok, follow}
          end
          
        false -> {:error, :not_local}
      end
    end)
  end

  defp unsubscribe(follow) do
    case Feeds.find_sub(follow.creator, follow.context.id) do
      {:ok, sub} -> Common.soft_delete(sub)
      _ -> {:ok, []} # shouldn't be here
    end
  end

end
