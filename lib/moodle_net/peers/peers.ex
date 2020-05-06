# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Peers do
  @moduledoc """
  Manages peers, servers with which we connect via synchronisation
  protocols, currently:

  * ActivityPub

  A `MoodleNet.Peers.Peer` is created from a MoodleNet.Meta.Pointer`
  as the `MoodleNet.Meta.Peer` participates in the Meta abstraction

  """
  alias MoodleNet.{Common, Meta, Peers, Repo}
  alias MoodleNet.Common.NotFoundError
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Peers.{Peer, Queries}

  # Querying

  @spec fetch(binary()) :: {:ok, Peer.t()} | {:error, NotFoundError.t()}
  @doc "Looks up the Peer with the given id in the database"
  def fetch(id), do: Repo.fetch(Peer, id)

  def one(filters \\ []), do: Repo.single(Queries.query(Peer, filters))
  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Peer, filters))}

  # Insertion

  @spec create(map()) :: {:ok, Peer.t()} | {:error, Changeset.t()}
  @doc "Create a Peer from the provided attributes"
  def create(attrs) do
    Repo.transact_with(fn ->
      Repo.insert(Peer.create_changeset(attrs))
    end)
  end

  # Updating

  @spec update(Peer.t(), map()) :: {:ok, Peer.t()} | {:error, Changeset.t()}
  @doc "Update the provided Peer with the provided attributes"
  def update(%Peer{} = peer, fields),
    do: Repo.update(Peer.update_changeset(peer, fields))

  # Soft deletion

  @spec soft_delete(Peer.t()) :: {:ok, Peer.t()} | {:error, DeletionError.t()}
  @doc "Marks a Peer as deleted in the database"
  def soft_delete(%Peer{} = peer), do: Common.soft_delete(peer)

  @spec soft_delete!(Peer.t()) :: Peer.t()
  @doc "Marks a Peer as deleted in the database or throws a DeletionError"
  def soft_delete!(%Peer{} = peer), do: Common.soft_delete!(peer)

  def soft_delete_by(filters) do
    Queries.query(Peer)
    |> Queries.filter(filters)
    |> Repo.delete_all()
  end

end
