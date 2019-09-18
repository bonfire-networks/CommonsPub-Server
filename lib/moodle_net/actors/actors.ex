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
      insert_revision(repo, actor, attrs)
    end)
    |> Repo.transaction()
  end

  def update(%Actor{} = actor, attrs \\ %{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:actor, Actor.update_changeset(actor, attrs))
    |> Ecto.Multi.run(:actor_revision, fn repo, %{actor: actor} ->
      insert_revision(repo, actor, attrs)
    end)
    |> Repo.transaction()
  end

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
end
