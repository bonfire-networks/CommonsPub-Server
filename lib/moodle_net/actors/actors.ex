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

  alias MoodleNet.{Actors, Meta, Repo}
  alias MoodleNet.Actors.{Actor, ActorRevision}
  alias MoodleNet.Meta.Pointer
  alias Ecto.{Changeset, Multi}

  @spec create(attrs :: map) :: {:ok, %Actor{}} :: {:error, Changeset.t()}
  def create(attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      actor_pointer = Meta.point_to!(Actor)

      with {:ok, actor} <- Repo.insert(Actor.create_changeset(actor_pointer, attrs)),
           {:ok, latest_revision} <- insert_revision(actor, attrs) do
        {:ok, %Actor{actor | latest_revision: latest_revision}}
      end
    end)
  end

  @spec create_with_alias(alias_id :: binary, attrs :: map) ::
          {:ok, %Actor{}} :: {:error, Changeset.t()}
  def create_with_alias(alias_id, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      with {:ok, actor} <- create(attrs) do
        actor
        |> Changeset.change(alias_id: alias_id)
        |> Repo.update()
      end
    end)
  end

  @spec update(actor :: %Actor{}, attrs :: map) :: {:ok, %Actor{}} :: {:error, Changeset.t()}
  def update(%Actor{} = actor, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      with {:ok, actor} <- Repo.update(Actor.update_changeset(actor, attrs)),
           {:ok, latest_revision} <- insert_revision(actor, attrs) do
        {:ok, %Actor{actor | latest_revision: latest_revision}}
      end
    end)
  end

  @spec delete(actor :: %Actor{}) :: {:ok, %Actor{}} | {:error, term}
  def delete(%Actor{} = actor) do
    # should cascade delete
    Repo.delete(actor)
  end

  defp insert_revision(actor, attrs) do
    actor_keys =
      actor
      |> Map.keys()
      |> Enum.map(&Atom.to_string/1)

    revision_attrs = Map.drop(attrs, actor_keys)

    actor
    |> ActorRevision.create_changeset(revision_attrs)
    |> Repo.insert()
  end
end
