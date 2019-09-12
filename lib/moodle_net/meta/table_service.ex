# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Meta.TableService do
  @moduledoc """
  An ets-based cache for mapping tables to their ids and vice versa.

  It looks up the tables from the database and populates an ets table
  with them during startup. After that it doesn't actually do anything
  apart from own the ets table - the `lookup` function just queries
  the ets table directly.
  """
  
  alias MoodleNet.Meta.{Table, TableService, TableNotFoundError}
  alias MoodleNet.Repo
  import Ecto.Query, only: [select: 3]

  use GenServer

  @service_name __MODULE__
  @table_name __MODULE__.Cache

  @type table_id :: binary() | integer()

  @type lookup_ok :: {:ok, integer() | binary()}
  @type lookup_error :: {:error, TableNotFoundError.t()}

  # public api

  @spec start_link() :: GenServer.on_start()
  @doc "Starts up the service registering it locally under this module's name"
  def start_link(),
    do: GenServer.start_link(__MODULE__, [name: @service_name])

  @spec lookup(table_id()) :: lookup_ok() | lookup_error()
  @doc "Look up a Table by name or id"
  def lookup(key) when is_integer(key) or is_binary(key),
    do: lookup_result(key, :ets.lookup(@table_name, key))
	  
  defp lookup_result(key, []), do: {:error, TableNotFoundError.new(key)}
  defp lookup_result(_, [{_,v}]), do: {:ok, v}

  @spec lookup!(table_id()) :: binary() | integer()
  @doc "Look up a Table by name or id, throw if not found"
  def lookup!(key) do
    case lookup(key) do
      {:ok, v} -> v
      {:error, reason} -> throw reason
    end
  end

  @spec lookup_id(table_id()) :: {:ok, integer()} | lookup_error()
  @doc "Look up a table id by id or name"
  def lookup_id(key) do
    with {:ok, val} <- lookup(key), do: {:ok, val.id}
  end

  @spec lookup!(table_id()) :: binary() | integer()
  @doc "Look up up a table id by id or name, throw if not found"
  def lookup_id!(key) do
    case lookup_id(key) do
      {:ok, v} -> v
      {:error, reason} -> throw reason
    end
  end

  # callbacks

  @doc false
  def init(_) do
    @table_name = :ets.new(@table_name, [:named_table])
    populate_table(@table_name)
    {:ok, []}
  end

  defp populate_table(table) do
    entries = Repo.all(Table)
    by_id = Enum.map(entries, fn table -> {table.id, table} end)
    by_table = Enum.map(entries, fn table -> {table.table, table} end)
    true = :ets.insert(table, by_id)
    true = :ets.insert(table, by_table)
  end

end
