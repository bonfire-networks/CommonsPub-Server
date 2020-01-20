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
  * Have a ULID primary key
  * Have a creation trigger that inserts a pointer on insertion
  * Have a deletion trigger that deletes a pointer on delete
  """

  alias MoodleNet.Repo
  alias MoodleNet.Common.{
    NotFoundError,
    NotInTransactionError,
  }
  alias MoodleNet.Meta.{
    Pointer,
    PointerDanglingError,
    PointerInsertError,
    PointerTypeError,
    Table,
    TableService,
  }

  @spec find(binary()) :: {:ok, Pointer.t()} | {:error, PointerNotFoundError.t()}
  @doc "Looks up a pointer by id"
  def find(id), do: find_result(Repo.get(Pointer, id), id)

  defp find_result(nil, id), do: {:error, NotFoundError.new(id)}
  defp find_result(pointer, _id), do: {:ok, pointer}

  @spec find!(binary()) :: Pointer.t()
  @doc "Looks up a pointer by id or throws a NotFoundError"
  def find!(id), do: find_result!(find(id))
    
  defp find_result!({:ok, v}), do: v
  defp find_result!({:error, e}), do: throw e


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

  defp point_to_result({:ok, v}), do: v
  defp point_to_result({:error, e}), do: throw PointerInsertError.new(e)

  defp pointer_changeset(table),
    do: Pointer.changeset(TableService.lookup_id!(table))

  @doc """
  Retrieves the Table that a pointer points to
  Note: Throws a TableNotFoundError if the table cannot be found
  """
  @spec points_to!(Pointer.t()) :: Table.t()
  def points_to!(%Pointer{table_id: id}), do: TableService.lookup!(id)

  @doc """
  Throws if the pointer does not point to the schema provided
  """
  @spec assert_points_to!(Pointer.t(), atom()) :: :ok
  def assert_points_to!(%Pointer{}=pointer, table) when is_atom(table) do
    if table == points_to!(pointer).schema,
      do: :ok,
      else: throw PointerTypeError.new(pointer)
  end

  @spec follow(Pointer.t) :: {:ok, any()} | {:error, PointerDanglingError.t}
  @doc """
  Follows the Pointer - look up up the record it points to
  Note: throws if the table in the pointer is invalid
  """
  def follow(%Pointer{id: id, table_id: table_id}=pointer) do
    table = TableService.lookup_schema!(table_id)
    follow_result(Repo.get(table, id), pointer)
  end

  defp follow_result(nil, pointer), do: {:error, PointerDanglingError.new(pointer)}
  defp follow_result(thing, _), do: {:ok, thing}

  @spec follow!(Pointer.t()) :: any()
  def follow!(%Pointer{}=pointer) do
    case follow(pointer) do
      {:ok, thing} -> thing
      {:error, e} -> throw e
    end
  end

end
