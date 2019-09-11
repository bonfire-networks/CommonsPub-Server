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
  * Have a UUID primary key which is also a foreign key to
    `MoodleNet.Meta.Pointer`
  * Have a deletion trigger that cascades the delete to
    `MoodleNet.Meta.Pointer`

  Insertion operations on participating tables must:

  * Insert a Pointer in the same transaction as an insert into the
    other table. This is so that in the event of the other insert
    failing, the Pointer will also be removed.
  """

  alias MoodleNet.Meta.{Pointer, Table, TableService}

  @spec pointer(table_or_id :: binary | integer) :: {:ok, %Pointer{}} | {:error, term}
  def pointer(table_or_id) do
    {:ok, table_id} = TableService.lookup(table_or_id)
    create_pointer(table_id)
  end

  # TODO: assume it's an ecto schema, attempt to query
  # def pointer(table, id) when is_atom(table) do
  # end

  defp create_pointer(table_id), do: Repo.insert(Pointer.changeset(table_id))
end
