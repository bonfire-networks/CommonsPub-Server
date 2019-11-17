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
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Meta.Pointer
  alias Ecto.{Changeset, Multi}

  @doc "Fetches an actor by id"
  @spec fetch(id :: binary) :: {:ok, Actor.t()} | {:error, NotFoundError.t()}
  def fetch(id) when is_binary(id), do: Repo.fetch(Actor, id)

  @doc "Fetches an actor by ID, ignoring whether if it is public or not."
  @spec fetch_private(id :: binary) :: {:ok, Actor.t()} | {:error, NotFoundError.t()}
  def fetch_private(id) when is_binary(id), do: Repo.fetch(Actor, id)

  @doc "Fetches n local actor by username"
  @spec fetch(username :: binary) :: {:ok, Actor.t()} | {:error, NotFoundError.t()}
  def fetch_by_username(username) when is_binary(username) do
    Repo.single(fetch_by_username_q(username))
  end

  @doc "Fetches a remote or a local actor by username"
  @spec fetch(username :: binary) :: {:ok, Actor.t()} | {:error, NotFoundError.t()}
  def fetch_any_by_username(username) when is_binary(username) do
    Repo.single(fetch_any_by_username_q(username))
  end

  defp fetch_by_username_q(username) do
    from a in Actor,
      where: a.preferred_username == ^username,
      where: is_nil(a.peer_id)
  end

  defp fetch_any_by_username_q(username) do
    from a in Actor,
    where: a.preferred_username == ^username
  end

  # a username remains taken forever and regardless of publicity
  defp is_username_available_q(username) do
    from a in Actor,
      where: a.preferred_username == ^username,
      where: is_nil(a.peer_id)
  end

  @doc "true if the provided preferred_username is available to register"
  @spec is_username_available?(username :: binary) :: boolean()
  def is_username_available?(username) when is_binary(username) do
    case Repo.single(is_username_available_q(username)) do
      {:ok, _} -> false
      _ -> true
    end
  end

  @doc "creates a new actor from the given attrs"
  @spec create(attrs :: map) :: {:ok, Actor.t()} :: {:error, Changeset.t()}
  def create(attrs) when is_map(attrs) do
    Repo.insert(Actor.create_changeset(attrs))
  end

  @spec update(actor :: Actor.t(), attrs :: map) :: {:ok, Actor.t()} :: {:error, Changeset.t()}
  def update(%Actor{} = actor, attrs) when is_map(attrs) do
    Repo.update(Actor.update_changeset(actor, attrs))
  end

  @spec delete(actor :: Actor.t()) :: {:ok, Actor.t()} | {:error, term}
  def delete(%Actor{} = actor), do: Repo.delete(actor)

end
