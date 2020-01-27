# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Meta.TableService do
  @moduledoc """
  An ets-based cache that allows lookup up Table objects by:

  * Database ID (integer)
  * Table name (string)
  * Ecto module name (atom)

  On startup:
  * The database is queried for a list of tables
  * The application is queried for a list of ecto schema modules
  * The two are collated, ensuring that schema modules exist for all tables
  * The data is inserted into an ets table owned by the process

  During operation, lookup requests will hit ets directly - this
  service exists solely to own the table and fit into the OTP
  supervision hierarchy neatly.
  """
  
  alias MoodleNet.Meta.{Introspection, Table, TableNotFoundError}
  alias MoodleNet.Repo

  use GenServer

  @init_query_name __MODULE__
  @service_name __MODULE__
  @table_name __MODULE__.Cache

  @type table_id :: binary() | integer() | atom()
  @type lookup_error :: {:error, term}

  # public api

  @spec start_link() :: GenServer.on_start()
  @doc "Starts up the service registering it locally under this module's name"
  def start_link(),
    do: GenServer.start_link(__MODULE__, [name: @service_name])

  @spec lookup(table_id()) :: {:ok, Table.t()} | {:error, TableNotFoundError.t()}
  @doc "Look up a Table by name, id or ecto module"
  def lookup(key) when is_integer(key) or is_binary(key) or is_atom(key),
    do: lookup_result(key, :ets.lookup(@table_name, key))
	  
  defp lookup_result(key, []), do: {:error, TableNotFoundError.new(key)}
  defp lookup_result(_, [{_,v}]), do: {:ok, v}

  @spec lookup!(table_id()) :: Table.t()
  @doc "Look up a Table by name or id, throw TableNotFoundError if not found"
  def lookup!(key) do
    case lookup(key) do
      {:ok, v} -> v
      {:error, reason} -> throw reason
    end
  end

  @spec lookup_id(table_id()) :: {:ok, integer()} | {:error, TableNotFoundError.t()}
  @doc "Look up a table id by id, name or schema"
  def lookup_id(key) do
    with {:ok, val} <- lookup(key), do: {:ok, val.id}
  end

  @spec lookup_id!(table_id()) :: integer()
  @doc "Look up up a table id by id, name or schema, throw TableNotFoundError if not found"
  def lookup_id!(key) do
    case lookup_id(key) do
      {:ok, v} -> v
      {:error, reason} -> throw reason
    end
  end

  @spec lookup_schema(table_id()) :: {:ok, atom()} | {:error, TableNotFoundError.t()}
  @doc "Look up a schema module by id, name or schema"
  def lookup_schema(key) do
    with {:ok, val} <- lookup(key), do: {:ok, val.schema}
  end

  @spec lookup_schema!(table_id()) :: atom()
  @doc "Look up a schema module by id, name or schema, throw TableNotFoundError if not found"
  def lookup_schema!(key) do
    case lookup_schema(key) do
      {:ok, v} -> v
      {:error, reason} -> throw reason
    end
  end

  # callbacks

  @doc false
  def init(_) do
    Table
    |> Repo.all(telemetry_event: @init_query_name)
    |> pair_schemata()
    |> populate_table()
    {:ok, []}
  end

  # Loops over entries, adding the module name of an Ecto Schema
  # operating over the referenced tables to the `schema` key. Errors
  # if a matching schema is not found
  defp pair_schemata(entries) do
    index = Enum.reduce(Introspection.ecto_schema_modules() ,%{}, fn module, acc ->
      schema_reduce(Introspection.ecto_schema_table(module), module, acc)
    end)
    Enum.map(entries, &pair_schema(&1, Map.get(index, &1.table)))
  end

  # Drop an entry where the table does not exist
  defp schema_reduce(nil, _, acc), do: acc
  defp schema_reduce(table, module, acc), do: Map.put(acc, table, module)

  # Error if there was no matching schema, otherwise add it to the entry
  defp pair_schema(entry, nil), do: throw {:missing_schema, entry.table}
  defp pair_schema(entry, schema), do: %{ entry | schema: schema }

  defp populate_table(entries) do
    :ets.new(@table_name, [:named_table])
    for field <- [:id, :table, :schema] do
      indexed = Enum.map(entries, &({ Map.get(&1,field), &1 }))
      true = :ets.insert(@table_name, indexed)
    end
  end

end
