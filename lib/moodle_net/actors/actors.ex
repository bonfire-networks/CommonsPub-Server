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

  alias MoodleNet.Repo
  alias MoodleNet.Actors
  alias MoodleNet.Actors.{Actor, ActorRevision}

  @attrs ~w(is_public)
  def attrs(attrs), do: Map.take(attrs, @attrs)

  @spec create(pointer_id :: integer, attrs :: map) :: {:ok, %Actor{}} :: {:error, Ecto.Changeset.t()}
  def create(pointer_id, attrs \\ %{}) do
    changes =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:actor, Actor.create_changeset(pointer_id, attrs))
      |> Ecto.Multi.run(:actor_revision, fn repo, %{actor: actor} ->
        insert_revision(repo, actor, attrs)
      end)
      |> Repo.transaction()

    parse_actor_changes(changes)
  end

  @spec update(actor :: %Actor{}, attrs :: map) :: {:ok, %Actor{}} :: {:error, Ecto.Changeset.t()}
  def update(%Actor{} = actor, attrs \\ %{}) do
    changes =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:actor, Actor.update_changeset(actor, attrs))
      |> Ecto.Multi.run(:actor_revision, fn repo, %{actor: actor} ->
        insert_revision(repo, actor, attrs)
      end)
      |> Repo.transaction()

    parse_actor_changes(changes)
  end

  @spec delete(actor :: %Actor{}) :: :ok | {:error, term}
  def delete(%Actor{} = actor) do
    # should cascade delete
    Repo.delete(actor)
  end

  defp insert_revision(repo, actor, attrs) do
    actor_keys =
      actor
      |> Map.keys()
      |> Enum.map(&Atom.to_string/1)

    revision_attrs = Map.drop(attrs, actor_keys)

    actor
    |> ActorRevision.create_changeset(revision_attrs)
    |> repo.insert()
  end

  defp parse_actor_changes({:ok, changes}),
    do: {:ok, Map.fetch!(changes, :actor)}

  defp parse_actor_changes({:error, _, changeset, _}), do: {:error, changeset}
end
