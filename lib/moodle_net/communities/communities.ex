# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Communities do
  import Ecto.Query, only: [from: 2]
  alias Ecto.Changeset
  alias MoodleNet.Actors.{
    Actor,
    ActorFollowerCount,
  }
  alias Ecto.Association.NotLoaded
  alias MoodleNet.{Actors, Collections, Common, Meta, Repo, Users}
  alias MoodleNet.Common.Query
  alias MoodleNet.Communities.Community
  alias MoodleNet.Localisation.Language
  alias MoodleNet.Users.User

  def count_for_list(), do: Repo.one(count_for_list_q())

  @doc "Lists public, non-deleted communities by follower count"
  def list(opts \\ %{})
  def list(%{}=opts) do
    Enum.map Repo.all(list_q()), fn {community, actor, count} ->
      %{community | actor: %{actor | follower_count: count}}
    end
  end

  defp count_for_list_q() do
    Community
    |> Query.only_public()
    |> Query.only_undeleted()
    |> Query.count()
  end

  def list_q() do
    from c in Community,
      join: a in Actor, on: a.alias_id == c.id,
      left_join: fc in assoc(a, :follower_count),
      where: not is_nil(c.published_at),
      where: is_nil(c.deleted_at),
      select: {c,a,fc},
      limit: 100,
      order_by: [desc: fc.count, desc: a.updated_at, desc: a.id]
  end

  @doc "Fetches a public, non-deleted community by id"
  def fetch(id) when is_binary(id) do
    with {:ok, {c,a}} <- Repo.single(fetch_q(id)) do
      {:ok, %{c | actor: a}}
    end
  end

  defp fetch_q(id) do
    from c in Community,
      inner_join: a in Actor, on: c.actor_id == a.id,
      where: a.id == ^id,
      where: not is_nil(c.published_at),
      where: not is_nil(a.published_at),
      where: is_nil(c.deleted_at),
      where: is_nil(a.deleted_at),
      select: {c,a}
  end

  @doc "Fetches a community by ID, ignoring whether it is public or not."
  @spec fetch_private(id :: binary) :: {:ok, Community.t} | {:error, NotFoundError.t}
  def fetch_private(id) when is_binary(id), do: Repo.fetch(Community, id)

  # @spec create(User.t, Actor.t, attrs :: map) :: {:ok, Community.t} | {:error, Changeset.t}
  # def create(%User{id: id}, %Actor{alias_id: alias_id} = creator, %{} = attrs)
  # when id == alias_id do
  #   Repo.transact_with fn ->
  #     with {:ok, comm} <- insert_community(creator, attrs),
  #          {:ok, actor} <- Actors.create_with_alias(comm.id, attrs) do
  # 	{:ok, %{ comm | actor: actor }}
  #     end
  #   end
  # end

  defp insert_community(creator, attrs) do
    Meta.point_to!(Community)
    |> Community.create_changeset(creator, attrs)
    |> Repo.insert()
  end

  @spec update(%Community{}, attrs :: map) :: {:ok, Community.t} | {:error, Changeset.t}
  def update(%Community{} = community, attrs) when is_map(attrs) do
    Repo.transact_with fn ->
      with {:ok, actor} <- fetch_actor(community),
           {:ok, community} <- Repo.update(Community.update_changeset(community, attrs)),
           {:ok, actor} <- Actors.update(actor, attrs) do
        {:ok, %{community | actor: actor}}
      end
    end
  end

  def soft_delete(%Community{} = community) do
    Repo.transact_with fn ->
      with {:ok, deleted} <- Common.soft_delete(community),
           {:ok, actor} <- fetch_actor(community),
           {:ok, actor} <- Actors.soft_delete(actor) do
        {:ok, deleted}
      end
    end
  end

  def fetch_actor(%Community{id: id, actor: nil}), do: Actors.fetch_by_alias(id)
  def fetch_actor(%Community{actor: actor}), do: {:ok, actor}

  def fetch_creator(%Community{creator_id: id, creator: %NotLoaded{}}), do: Actors.fetch(id)
  def fetch_creator(%Community{creator: creator}), do: {:ok, creator}

end
