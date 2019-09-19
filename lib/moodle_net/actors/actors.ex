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

  @attrs ~w(is_public)
  def attrs(attrs), do: Map.take(attrs, @attrs)


  @spec create(attrs :: map) :: {:ok, Actor.t} :: {:error, Changeset.t}
  @spec create(multi :: Multi.t, attrs :: map) :: {:ok, Actor.t} :: {:error, Changeset.t}
  def create(multi \\ Multi.new(), attrs) when is_map(attrs) do
    create_multi(multi, attrs)
    |> Repo.transaction()
    |> parse_actor_changes()
  end

  @spec create_multi(attrs :: map) :: Multi.t
  @spec create_multi(multi :: Multi.t, attrs :: map) :: Multi.t
  def create_multi(multi \\ Multi.new(), attrs) when is_map(attrs) do
    multi
    |> Ecto.Multi.insert(:actor_pointer, Meta.pointer_changeset(Actor))
    |> Ecto.Multi.run(:actor, fn repo, ctx ->
      repo.insert(Actor.create_changeset(ctx.actor_pointer, attrs))
    end)
    |> Ecto.Multi.run(:actor_revision, fn repo, ctx ->
      insert_revision(repo, ctx.actor, attrs)
    end)
  end

  @spec update(actor :: Actor.t, attrs :: map) :: {:ok, Actor.t} :: {:error, Changeset.t}
  @spec update(multi :: Multi.t, actor :: Actor.t, attrs :: map) :: {:ok, Actor.t} :: {:error, Changeset.t}
  def update(multi \\ Multi.new(), %Actor{} = actor, attrs) when is_map(attrs) do
    multi
    |> update_multi(actor, attrs)
    |> Repo.transaction()
    |> parse_actor_changes()
  end

  @spec update_multi(actor :: Actor.t, attrs :: map) :: Multi.t
  @spec update_multi(multi :: Multi.t, actor :: Actor.t, attrs :: map) :: Multi.t
  def update_multi(multi \\ Multi.new(), %Actor{} = actor, attrs) when is_map(attrs) do
    multi
    |> Ecto.Multi.update(:actor, Actor.update_changeset(actor, attrs))
    |> Ecto.Multi.run(:actor_revision, fn repo, ctx -> insert_revision(repo, ctx.actor, attrs) end)
  end

  @spec delete(actor :: Actor.t) :: {:ok, Actor.t} | {:error, term}
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
