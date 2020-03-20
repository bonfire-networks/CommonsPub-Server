# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
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
  alias MoodleNet.Repo
  alias MoodleNet.Actors.{Actor, Queries}
  alias Ecto.Changeset

  def one(filters), do: Repo.single(Queries.query(Actor, filters))

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
  @spec create(attrs :: map) :: {:ok, Actor.t()} | {:error, Changeset.t()}
  def create(attrs) when is_map(attrs) do
    Repo.insert(Actor.create_changeset(attrs))
  end

  @spec update(actor :: Actor.t(), attrs :: map) :: {:ok, Actor.t()} | {:error, Changeset.t()}
  def update(%Actor{} = actor, attrs) when is_map(attrs) do
    Repo.update(Actor.update_changeset(actor, attrs))
  end

  @spec delete(actor :: Actor.t()) :: {:ok, Actor.t()} | {:error, term}
  def delete(%Actor{} = actor), do: Repo.delete(actor)

end
