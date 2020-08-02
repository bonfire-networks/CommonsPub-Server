# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Actors do
  @doc """
  A Context for dealing with Characters.
  Actors come in several kinds:

  * Users
  * Communities
  * Collections
  """

  alias MoodleNet.Actors.{Actor, Queries}
  alias MoodleNet.Repo
  alias MoodleNet.Users.User
  alias Ecto.Changeset

  def one(filters), do: Repo.single(Queries.query(Actor, filters))

  @doc "creates a new actor from the given attrs"
  @spec create(attrs :: map) :: {:ok, Actor.t()} | {:error, Changeset.t()}
  def create(attrs) when is_map(attrs) do
    # attrs = Map.put(attrs, :preferred_username, atomise_username(Map.get(attrs, :preferred_username)))
    Repo.transact_with(fn ->
      with {:ok, actor} <- Repo.insert(Actor.create_changeset(attrs)) do
        if is_nil(actor.peer_id) do
          case CommonsPub.Character.Characters.reserve_username(attrs.preferred_username) do
            {:ok, _} -> {:ok, actor}
            _ -> {:error, "Username already taken"}
          end
        else
          {:ok, actor}
        end
      end
    end)
  end

  @spec update(user :: User.t(), actor :: Actor.t(), attrs :: map) ::
          {:ok, Actor.t()} | {:error, Changeset.t()}
  def update(%User{}, %Actor{} = actor, attrs) when is_map(attrs) do
    Repo.update(Actor.update_changeset(actor, attrs))
  end
end
