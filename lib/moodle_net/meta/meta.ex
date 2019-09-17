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
  alias MoodleNet.Peers.Peer
  alias MoodleNet.Meta.{
    Introspection,
    NotInTransactionError,
    Pointer,
    PointerDanglingError,
    PointerInsertError,
    PointerNotFoundError,
    Table,
    TableNotFoundError,
    TableService,
  }

  @spec find(binary()) :: {:ok, Pointer.t()} | {:error, PointerNotFoundError.t()}
  @doc "Looks up a pointer by id"
  def find(id), do: find_result(Repo.get(Pointer, id), id)

  defp find_result(nil, id), do: {:error, PointerNotFoundError.new(id)}
  defp find_result(pointer, id), do: {:ok, pointer}

  @spec find!(binary()) :: Pointer.t()
  @doc "Looks up a pointer by id or throws a PointerNotFoundError"
  def find!(id), do: find_result!(find(id))
    
  defp find_result!({:ok, v}), do: v
  defp find_result!({:error, e}), do: throw e


  @spec follow!(Pointer.t()) :: any()
  @doc """
  Follows the Pointer - look up up the record it points to
  Note: throws if the table in the pointer is invalid or the pointed value is not found
  """
  def follow!(%Pointer{id: id, table_id: table_id}=pointer) do
    table = TableService.lookup_schema!(table_id)
    follow_result(Repo.get(table, id), pointer)
  end

  defp follow_result(nil, pointer), do: {:error, PointerDanglingError.new(pointer)}
  defp follow_result(thing, _), do: thing

  # TODO: following many
  # def follow_many(pointers) when is_list(pointers) do
  #   plan = follow_many_plan(pointers)
  #   Enum.sort_by
  # end

  # defp follow_many_plan(pointers) when is_list(pointers),
  #   do: Enum.reduce(pointers, %{}, &follow_one_plan/2)

  # defp follow_one_plan(%Pointer{id: id, table_id: table_id}, acc) do
  #   case Map.fetch(acc, table_id) do
  #     {:ok, ids} -> Map.put(acc, table_id, [id | ids])
  #     _ -> Map.put(acc, table_id, [id])
  #   end
  # end

  @doc """
  Creates a Pointer in the database, pointing to the given table or throws
  Note: throws NotInTransactionError unless you're in a transaction
  """
  @spec point!(TableService.table_id()) :: Pointer.t()
  def point!(table) do
    if not Repo.in_transaction?(),
      do: throw NotInTransactionError.new(table)
      
    table
    |> point_changeset()
    |> Repo.insert()
    |> point_result()
  end

  defp point_result({:ok, v}), do: v
  defp point_result({:error, e}), do: throw PointerInsertError.new(e)

  defp point_changeset(table),
    do: Pointer.changeset(TableService.lookup_id!(table))

  @doc """
  Retrieves the Table that a pointer points to
  Note: Throws a TableNotFoundError if the table cannot be found
  """
  @spec points_to!(Pointer.t()) :: Table.t()
  def points_to!(%Pointer{table_id: id}), do: TableService.lookup!(id)

end
