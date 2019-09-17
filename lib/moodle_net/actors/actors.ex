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

  def create(pointer_id, attrs \\ %{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:actor, Actor.create_changeset(pointer_id, attrs))
    |> Ecto.Multi.run(:actor_revision, fn repo, %{actor: actor} ->
      insert_revision(actor, attrs)
    end)
    |> Repo.transaction()
  end

  def update(%Actor{} = actor, attrs \\ %{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:actor, Actor.update_changeset(actor, attrs))
    |> Ecto.Multi.run(:actor_revision, fn repo, %{actor: actor} ->
      insert_revision(actor, attrs)
    end)
    |> Repo.transaction()
  end

  def delete(%Actor{} = actor) do
    # should cascade delete
    Repo.delete(actor)
  end

  defp insert_revision(actor, attrs) do
    actor_keys =
      actor
      |> Map.keys()
      |> Enum.map(&Atom.to_string/1)

    actor_attrs = Map.drop(attrs, actor_keys)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:actor_revision, ActorRevision.create_changeset(actor, actor_attrs))
    |> Ecto.Multi.run(:actor_revision_extras, fn repo, %{actor_revision: actor_revision} ->
      actor_keys =
        actor
        |> Map.keys()
        |> Enum.map(&Atom.to_string/1)

      revision_keys =
        actor_revision
        |> Map.keys()
        |> Enum.map(&Atom.to_string/1)

      extra_attrs = Map.drop(attrs, actor_keys ++ revision_keys)

      actor_revision
      |> ActorRevision.update_extra(extra_attrs)
      |> repo.update()
    end)
    |> Repo.transaction()
  end
end
