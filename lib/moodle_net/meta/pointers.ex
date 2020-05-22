# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Meta.Pointers do

  alias MoodleNet.Meta.{Pointer, PointersQueries, TableService}
  alias MoodleNet.Repo

  def one(filters), do: Repo.single(PointersQueries.query(Pointer, filters))

  def one!(filters), do: Repo.one!(PointersQueries.query(Pointer, filters))

  def many(filters \\ []), do: {:ok, Repo.all(PointersQueries.query(Pointer, filters))}

  def maybe_forge!(%Pointer{} = pointer), do: pointer
  def maybe_forge!(%{__struct__: _} = pointed), do: forge!(pointed)

  @doc """
  Retrieves the Table that a pointer points to
  Note: Throws a TableNotFoundError if the table cannot be found
  """
  @spec table!(Pointer.t()) :: Table.t()
  def table!(%Pointer{table_id: id}), do: TableService.lookup!(id)

  @doc """
  Forge a pointer from a structure that participates in the meta abstraction.

  Does not hit the database, is safe so long as the provided struct
  participates in the meta abstraction
  """
  @spec forge!(%{__struct__: atom, id: binary}) :: %Pointer{}
  def forge!(%{__struct__: table_id, id: id} = pointed) do
    table = TableService.lookup!(table_id)
    %Pointer{id: id, table: table, table_id: table.id, pointed: pointed}
  end

  @doc """
  Forges a pointer to a participating meta entity.

  Does not hit the database, is safe so long as the entry we wish to
  synthesise a pointer for represents a legitimate entry in the database.
  """
  @spec forge!(table_id :: integer | atom, id :: binary) :: %Pointer{}
  def forge!(table_id, id) do
    table = TableService.lookup!(table_id)
    %Pointer{id: id, table: table, table_id: table.id}
  end

  def follow!(pointer_or_pointers) do
    case preload!(pointer_or_pointers) do
      %Pointer{}=pointer -> pointer.pointed
      pointers -> Enum.map(pointers, &(&1.pointed))
    end
  end

  @spec preload!(Pointer.t | [Pointer.t]) :: Pointer.t | [Pointer.t]
  @spec preload!(Pointer.t | [Pointer.t], list) :: Pointer.t | [Pointer.t]
  @doc """
  Follows one or more pointers and adds the pointed records to the `pointed` attrs
  """
  def preload!(pointer_or_pointers, opts \\ [])
  def preload!(%Pointer{id: id, table_id: table_id}=pointer, opts) do
    if is_nil(pointer.pointed) or Keyword.get(opts, :force) do
      {:ok, [pointed]} = loader(table_id, id: id)
      %{ pointer | pointed: pointed }
    else
      pointer
    end
  end
  def preload!(pointers, opts) when is_list(pointers) do
    pointers
    |> preload_load(opts)
    |> preload_collate(pointers)
  end
  def preload!(%{__struct__: _}=pointed, _), do: pointed

  defp preload_collate(loaded, pointers), do: Enum.map(pointers, &collate(loaded, &1))

  defp collate(_, nil), do: nil
  defp collate(loaded, %{}=p), do: %{ p | pointed: Map.get(loaded, p.id, %{}) }

  defp preload_load(pointers, opts) do
    force = Keyword.get(opts, :force, false)
    pointers
    |> Enum.reduce(%{}, &preload_search(force, &1, &2)) # find ids
    |> Enum.reduce(%{}, &preload_per_table/2)           # query
  end

  defp preload_search(false, %{pointed: pointed}, acc)
  when not is_nil(pointed), do: acc

  defp preload_search(_force, pointer, acc) do
    ids = [ pointer.id | Map.get(acc, pointer.table_id, []) ]
    Map.put(acc, pointer.table_id, ids)
  end

  defp preload_per_table({table_id, ids}, acc) do
    {:ok, items} = loader(table_id, id: ids)
    Enum.reduce(items, acc, &Map.put(&2, &1.id, &1))
  end

  defp loader(schema, filters) when not is_atom(schema) do
    loader(TableService.lookup_schema!(schema), filters)
  end
  defp loader(schema, filters) do
    module = apply(schema, :queries_module, [])
    filters = apply(schema, :follow_filters, []) ++ filters
    {:ok, Repo.all(apply(module, :query, [schema, filters]))}
  end

end
