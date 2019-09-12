# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Meta do
  @moduledoc """
  The meta system is for solving the problem of dynamism being
  required by parts of the system - that is, for a foreign key to be
  able to identify a row in any one of a predetermined list of tables.

  A `MoodleNet.Meta.Table` identifies a participating table.

  A `MoodleNet.Meta.Pointer` is a reference to an entry in a
  participating table.

  ## Rules
  
  Participating tables must:

  * Have an entry in `MoodleNet.Meta.Table`

  * Have a UUID primary key which is also a foreign key which
    references `MoodleNet.Meta.Pointer`

  * Have a deletion trigger that cascades the delete to
    `MoodleNet.Meta.Pointer` (TODO - delete the pointer for now and it will cascade)

  Insertion operations on participating tables must:

  * Insert a Pointer in the same transaction as an insert into the
    other table. This is so that in the event of the other insert
    failing, the Pointer will also be removed.
  """

  alias Ecto.Changeset
  alias MoodleNet.Repo
  alias MoodeNet.Peers.Peer
  alias MoodleNet.Meta.{Pointer, Table, TableService, NotInTransactionError}

  def find(id), do: Repo.get(Pointer, id)
  def find!(id), do: Repo.get!(Pointer, id)

  # @meta_tables %{
  #   "mn_peer" => Peer,
  # }
  # def follow(%Pointer{id: id, table_id: table_id}),
  #   do: Repo.get(Pointer,
  # end

  @doc """
  Creates a Pointer in the database, pointing to the given table or throws
  Note: Requires being in a transaction!
  """
  @spec point!(TableService.table_id()) :: Pointer.t()
  def point!(table) do
    if not Repo.in_transaction?(),
      do: throw NotInTransactionError.new({__MODULE__, :pointer!, [table]})
    Repo.insert!(point_changeset!(table))
  end

  @doc "Creates a changeset for a pointer to an entry in the provided table or throws"
  @spec point_changeset!(TableService.table_id()) :: Changeset.t()
  def point_changeset!(table),
    do: Pointer.changeset(TableService.lookup_id!(table))

end
