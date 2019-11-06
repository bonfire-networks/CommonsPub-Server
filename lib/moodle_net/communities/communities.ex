# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Communities do
  import Ecto.Query, only: [from: 2]
  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor
  alias MoodleNet.{Actors, Common, Meta, Repo, Users}
  alias MoodleNet.Communities.Community
  alias MoodleNet.Localisation.Language
  alias MoodleNet.Users.User

  def list(%{}=opts) do
    list_q()
    |> Common.paginate(opts)
  end

  def list_q() do
    from c in Community,
      where: c.is_public == true
  end

  def fetch(id) when is_binary(id) do
    query =
      from(c in Community,
        where: c.id == ^id,
        where: not is_nil(c.published_at)
      )
    Repo.single(query)
  end

  @doc "Fetches a community by ID, ignoring whether it is public or not."
  @spec fetch_private(id :: binary) :: {:ok, Community.t} | {:error, NotFoundError.t}
  def fetch_private(id) when is_binary(id), do: Repo.fetch(Community, id)

  @spec create(User.t, Actor.t, attrs :: map) :: {:ok, Community.t} | {:error, Changeset.t}
  def create(%User{id: id}, %Actor{alias_id: alias_id} = creator, %{} = attrs)
  when id == alias_id do
    Repo.transact_with fn ->
      with {:ok, comm} <- insert_community(creator, attrs),
           {:ok, actor} <- Actors.create_with_alias(comm.id, attrs) do
	{:ok, %{ comm | actor: actor }}
      end
    end
  end

  defp insert_community(creator, attrs) do
    Meta.point_to!(Community)
    |> Community.create_changeset(creator, attrs)
    |> Repo.insert()
  end

  # TODO: update actor
  @spec update(%Community{}, attrs :: map) :: {:ok, Community.t} | {:error, Changeset.t}
  def update(%Community{} = community, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      community
      |> Community.update_changeset(attrs)
      |> Repo.update()
    end)
  end

  def follow(%User{} = user, %Community{} = community) do
    with {:ok, actor} <- Users.fetch_actor(user) do
      case Common.find_follow(actor, community) do
	{:ok, follow} -> {:error, AlreadyFollowingError.new(community.id)}
	_ ->
	  with {:ok, _} <- Common.follow(actor, community) do
	    {:ok, true}
	  end
      end
    end
  end

  def unfollow(%Actor{} = actor, %Community{} = community) do

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

end
