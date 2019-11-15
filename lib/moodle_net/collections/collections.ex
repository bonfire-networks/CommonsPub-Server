# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Collections do
  alias MoodleNet.{Common, Meta, Repo}
  alias MoodleNet.Actors
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Common.Query
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Users.User
  alias Ecto.Association.NotLoaded
  import Ecto.Query

  def count_for_list(), do: Repo.one(count_for_list_q())

  @spec list() :: [Collection.t()]
  def list() do
    Enum.map(Repo.all(list_q()), fn {collection, actor, count} ->
      %Collection{collection | actor: actor, follower_count: count}
    end)
  end

  defp list_q() do
    Collection
    |> Query.only_public()
    |> Query.only_undeleted()
    |> Query.order_by_recently_updated()
    |> only_from_undeleted_communities()
    |> follower_count_q()
  end

  defp only_from_undeleted_communities(query) do
    from(q in query,
      join: c in assoc(q, :community),
      on: q.community_id == c.id,
      where: is_nil(c.deleted_at)
    )
  end

  defp follower_count_q(query) do
    from(q in query,
      join: a in Actor,
      on: a.id == q.actor_id,
      left_join: fc in assoc(q, :follower_count),
      select: {q, a, fc},
      limit: 100,
      order_by: [desc: fc.count, desc: a.id]
    )
  end

  defp count_for_list_q() do
    Collection
    |> Query.only_public()
    |> Query.only_undeleted()
    |> only_from_undeleted_communities()
    |> Query.count()
  end

  def count_for_list_in_community(%Actor{id: id}) do
    Repo.one(Query.count(list_in_community_q(id)))
  end

  def list_in_community(%Community{id: id}) do
    Repo.all(list_in_community_q(id))
  end

  defp list_in_community_q(id) do
    from(coll in Collection,
      join: comm in Community,
      on: coll.community_id == comm.id,
      join: a in Actor,
      on: coll.actor_id == a.id,
      where: comm.id == ^id,
      where: not is_nil(coll.published_at),
      where: is_nil(coll.deleted_at),
      where: not is_nil(comm.published_at),
      where: is_nil(comm.deleted_at)
    )
  end

  defp count_for_list_in_community_q(id), do: Query.count(list_in_community_q(id))

  def fetch(id) when is_binary(id), do: Repo.single(fetch_q(id))

  defp fetch_q(id) do
    from(coll in Collection,
      join: comm in Community,
      on: coll.community_id == comm.id,
      join: a in Actor,
      on: coll.actor_id == a.id,
      where: coll.id == ^id,
      where: not is_nil(coll.published_at),
      where: is_nil(coll.deleted_at),
      where: not is_nil(comm.published_at),
      where: is_nil(comm.deleted_at)
    )
  end

  @spec create(Community.t(), User.t(), attrs :: map) ::
          {:ok, Collection.t()} | {:error, Changeset.t()}
  def create(%Community{} = community, %User{} = creator, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      with {:ok, actor} <- Actors.create(attrs),
           {:ok, coll} <- insert_collection(community, creator, actor, attrs) do
        {:ok, %Collection{coll | actor: actor, creator: creator}}
      end
    end)
  end

  defp insert_collection(community, creator, actor, attrs) do
    Meta.point_to!(Collection)
    |> Collection.create_changeset(community, creator, actor, attrs)
    |> Repo.insert()
  end

  @spec update(%Collection{}, attrs :: map) :: {:ok, Collection.t()} | {:error, Changeset.t()}
  def update(%Collection{} = collection, attrs) do
    Repo.transact_with(fn ->
      with {:ok, actor} <- fetch_actor(collection),
           {:ok, collection} <- Repo.update(Collection.update_changeset(collection, attrs)),
           {:ok, actor} <- Actors.update(actor, attrs) do
        {:ok, %Collection{collection | actor: actor}}
      end
    end)
  end

  def soft_delete(%Collection{} = collection), do: Common.soft_delete(collection)

  def preload(%Collection{} = collection, opts \\ []),
    do: Repo.preload(collection, [:actor, :creator], opts)

  def fetch_actor(%Collection{actor_id: id, actor: %NotLoaded{}}), do: Actors.fetch(id)
  def fetch_actor(%Collection{actor: actor}), do: {:ok, actor}

  def fetch_creator(%Collection{creator_id: id, creator: %NotLoaded{}}), do: Actors.fetch(id)
  def fetch_creator(%Collection{creator: creator}), do: {:ok, creator}

end
