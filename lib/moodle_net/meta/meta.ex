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
  alias MoodleNet.Common.NotInTransactionError
  alias MoodleNet.Meta.{
    Introspection,
    Pointer,
    PointerDanglingError,
    PointerInsertError,
    PointerNotFoundError,
    PointerTypeError,
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
  @spec point_to!(TableService.table_id()) :: Pointer.t()
  def point_to!(table) do
    if not Repo.in_transaction?(),
      do: throw NotInTransactionError.new(table)
      
    table
    |> pointer_changeset()
    |> Repo.insert()
    |> point_to_result()
  end

  @doc """
  Create a pointer using a structure that participates in the meta abstraction.
  """
  @spec forge!(%{__struct__: atom, id: binary}) :: %Pointer{}
  def forge!(%{__struct__: table_id, id: id} = pointed) do
    table = TableService.lookup!(table_id)
    %Pointer{id: id, table: table, table_id: table.id, pointed: pointed}
  end

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

  @spec preload!(Pointer.t | [Pointer.t]) :: Pointer.t | [Pointer.t]
  @spec preload!(Pointer.t | [Pointer.t], list) :: Pointer.t | [Pointer.t]
  @doc """
  Follows one or more pointers and adds the pointed records to the `pointed` attrs
  """
  def preload!(pointer_or_pointers, opts \\ [])
  def preload!(%Pointer{}=pointer, opts) do
    if is_nil(pointer.pointed) or Keyword.get(opts, :force),
      do: %{ pointer | pointed: follow!(pointer) },
      else: pointer
  end
  def preload!(pointers, opts) when is_list(pointers) do
    pointers
    |> preload_load(opts)
    |> preload_collate(pointers)
  end

  defp preload_collate(loaded, pointers),
    do: Enum.map(pointers, fn p -> %{ p | pointed: Map.fetch!(loaded, p.id) } end)

  defp preload_load(pointers, opts) do
    force = Keyword.get(opts, :force, false)
    pointers
    |> Enum.reduce(%{}, &preload_search(force, &1, &2)) # find ids
    |> Enum.reduce(%{}, &preload_per_table/2)           # query
  end
  
  defp preload_search(false, %{pointed: pointed}=pointer, acc)
  when not is_nil(pointed), do: acc
  
  defp preload_search(_force, pointer, acc) do
    ids = [ pointer.id | Map.get(acc, pointer.table_id, []) ]
    Map.put(acc, pointer.table_id, ids)
  end
    
  defp preload_per_table({table_id, ids}, acc) do
    load_many(table_id, ids)
    |> Enum.reduce(acc, &Map.put(&2, &1.id, &1))
  end
  import Ecto.Query
  
  defp load_many(table_id, ids) do
    TableService.lookup_schema!(table_id)
    |> load_many_query(ids)
    |> Repo.all()
  end

  defp load_many_query(schema, ids) do
    from s in schema, where: s.id in ^ids
  end

end
