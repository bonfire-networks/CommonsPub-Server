# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Actors do
  @doc """
  A Context for dealing with Actors.
  Actors come in several kinds:

  * Users
  * Communities
  * Collections
  """

  import Ecto.Query, only: [from: 2]
  alias MoodleNet.{Actors, Meta, Repo}
  alias MoodleNet.Actors.{Actor, ActorRevision, ActorLatestRevision}
  alias MoodleNet.Common.Revision
  alias MoodleNet.Meta.Pointer
  alias Ecto.{Changeset, Multi}

  @doc "Fetches an actor by id"
  @spec fetch(id :: binary) :: {:ok, Actor.t()} | {:error, NotFoundError.t()}
  def fetch(id) when is_binary(id) do
    query =
      from(a in Actor,
        where: a.id == ^id,
        where: not is_nil(a.published_at)
      )

    preload_current_revision(Repo.single(query))
  end

  @doc "Fetches an actor by ID, regardless if it is public or not."
  @spec fetch_private(id :: binary) :: {:ok, Actor.t()} | {:error, NotFoundError.t()}
  def fetch_private(id) when is_binary(id) do
    preload_current_revision(Repo.fetch(Actor, id))
  end

  # TODO: one query
  @spec fetch_by_alias(id :: binary) :: {:ok, Actor.t()} | {:error, NotFoundError.t()}
  def fetch_by_alias(alias_id) when is_binary(alias_id),
    do: preload_current_revision(Repo.fetch_by(Actor, alias_id: alias_id))

  # TODO: one query
  @doc "Fetches an actor by username"
  @spec fetch(username :: binary) :: {:ok, Actor.t()} | {:error, NotFoundError.t()}
  def fetch_by_username(username) when is_binary(username),
    do: preload_current_revision(Repo.fetch_by(Actor, preferred_username: username))

  defp preload_current_revision({:ok, actor}), do: {:ok, Repo.preload(actor, :current)}
  defp preload_current_revision(error), do: error

  @doc "true if the provided preferred_username is available to register"
  @spec is_username_available?(username :: binary) :: boolean()
  def is_username_available?(username) when is_binary(username) do
    case fetch_by_username(username) do
      {:ok, _} -> false
      _ -> true
    end
  end

  @doc "creates a new actor from the given attrs"
  @spec create(attrs :: map) :: {:ok, Actor.t()} :: {:error, Changeset.t()}
  def create(attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      actor_pointer = Meta.point_to!(Actor)

      with {:ok, actor} <- Repo.insert(Actor.create_changeset(actor_pointer, attrs)),
           {:ok, revision} <- Revision.insert(ActorRevision, actor, attrs) do
        latest_revision = ActorLatestRevision.forge(revision)
        {:ok, %Actor{actor | latest_revision: latest_revision, current: revision}}
      end
    end)
  end

  @spec create_with_alias(alias_id :: binary, attrs :: map) ::
          {:ok, Actor.t()} :: {:error, Changeset.t()}
  def create_with_alias(alias_id, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      with {:ok, actor} <- create(attrs) do
        actor
        |> Changeset.change(alias_id: alias_id)
        |> Repo.update()
      end
    end)
  end

  @spec update(actor :: Actor.t(), attrs :: map) :: {:ok, Actor.t()} :: {:error, Changeset.t()}
  def update(%Actor{} = actor, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      with {:ok, actor} <- Repo.update(Actor.update_changeset(actor, attrs)),
           {:ok, revision} <- Revision.insert(ActorRevision, actor, attrs) do
        latest_revision = ActorLatestRevision.forge(revision)
        {:ok, %Actor{actor | latest_revision: latest_revision, current: revision}}
      end
    end)
  end

  @spec delete(actor :: Actor.t()) :: {:ok, Actor.t()} | {:error, term}
  def delete(%Actor{} = actor) do
    # should cascade delete
    Repo.delete(actor)
  end
end
