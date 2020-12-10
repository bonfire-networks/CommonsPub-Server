defmodule Pointers.Tables do
  @moduledoc """
  A Global cache of Tables to be queried by their (Pointer) IDs, table
  names or Ecto Schema module names.

  Use of the Table Service requires:

  1. You have run the migrations shipped with this library.
  2. You have started `Pointers.Tables` before querying.
  3. All OTP applications with pointable Ecto Schemata to be added to the schema path.
  4. OTP 21.2 or greater, though we recommend using the most recent release available.

  While this module is a GenServer, it is only responsible for setup
  of the cache and then exits with :ignore having done so. It is not
  recommended to restart the service as this will lead to a stop the
  world garbage collection of all processes and the copying of the
  entire cache to each process that has queried it since its last
  local garbage collection.
  """
  alias Pointers.{NotFound, Table, ULID}

  use GenServer, restart: :transient

  require Logger

  @typedoc """
  A query is either a table's (database) name or (Pointer) ID as a
  binary or the name of its Ecto Schema Module as an atom.
  """
  @type query :: binary | atom


  @spec start_link(ignored :: term) :: GenServer.on_start()
  @doc "Populates the global cache with table data via introspection."
  def start_link(_), do: GenServer.start_link(__MODULE__, [])

  def data(), do: :persistent_term.get(__MODULE__)

  @spec table(query :: query) :: {:ok, Table.t()} | {:error, NotFound.t()}
  @doc "Get a Table identified by name, id or module."
  def table(query) when is_binary(query) or is_atom(query) do
    case Map.get(data(), query) do
      nil -> {:error, NotFound.new()}
      other -> {:ok, other}
    end
  end

  @spec table!(query) :: Table.t()
  @doc "Look up a Table by name or id, raise NotFound if not found."
  def table!(query), do: Map.get(data(), query) || raise(NotFound)

  @spec id(query) :: {:ok, integer()} | {:error, NotFound}
  @doc "Look up a table id by id, name or schema."
  def id(query), do: with({:ok, val} <- table(query), do: {:ok, val.id})

  @spec id!(query) :: integer()
  @doc "Look up a table id by id, name or schema, raise NotFound if not found."
  def id!(query) when is_atom(query) or is_binary(query), do: id!(query, data())

  @spec ids!([binary | atom]) :: [binary]
  @doc "Look up many ids at once, raise NotFound if any of them are not found"
  def ids!(ids) do
    data = data()
    Enum.map(ids, &id!(&1, data)) |> Enum.filter(& !is_nil(&1))
  end

  # called by id!/1, ids!/1
  defp id!(query, data), do: Map.get(data, query, %{}) |> Map.get(:id, nil) || raise(NotFound)

  @spec schema(query) :: {:ok, atom} | {:error, NotFound.t()}
  @doc "Look up a schema module by id, name or schema"
  def schema(query), do: with({:ok, val} <- table(query), do: {:ok, val.schema})

  @spec schema!(query) :: atom
  @doc "Look up a schema module by id, name or schema, raise NotFound if not found"
  def schema!(query), do: table!(query).schema

  # GenServer callback

  def init(_) do
    # MODIFIED VERSION OF Pointers.Table to support old/deprecating pointer tables

    try do
      pointables = CommonsPub.Pointers.Tables.fetch_list()
      # |> IO.inspect()

      indexed = pointables |> Enum.reduce(%{}, &index/2)
      # |> IO.inspect()

      :persistent_term.put(__MODULE__, indexed)

      Logger.warn("TableService started")

      :ignore
    rescue
      e ->
        Logger.warn("TableService could not init because: #{inspect(e, pretty: true)}")
        :ignore
    end
  end

  defp index(t, acc) do
    # t = %Table{id: id, schema: mod, table: table}
    Map.merge(acc, %{t.id => t, t.table => t, t.schema => t})
  end

  @doc "Lists all pointable tables we know"
  def list_pointable_schemas() do
    pointable_tables = data()

    Enum.reduce(pointable_tables, [], fn x, acc ->
      Enum.concat(acc, [x.schema])
    end)
  end
end
