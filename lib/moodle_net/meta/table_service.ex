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
  
  alias MoodleNet.Meta.{Table, TableService}
  alias MoodleNet.Repo
  import Ecto.Query, only: [select: 3]

  use GenServer

  @service_name __MODULE__
  @table_name __MODULE__.Cache

  # public api

  @spec start_link() :: GenServer.on_start()
  @doc "Starts up the service registering it locally under this module's name"
  def start_link(),
    do: GenServer.start_link(__MODULE__, [name: @service_name])

  @spec lookup(integer() | binary()) :: {:ok, integer() | binary()} | :error
  @doc "Look up a table name by id or id by name"
  def lookup(key) when is_integer(key) or is_binary(key),
    do: lookup_result(:ets.lookup_element(@table_name, key, 2))
	  
  defp lookup_result([]), do: :error
  defp lookup_result([v]), do: {:ok, v}

  # callbacks

  @doc false
  def init(_) do
    @table_name = :ets.new(@table_name, [:named_table])
    populate_table(@table_name)
    {:ok, []}
  end

  import Ecto.Query, only: [select: 3]

  defp query(), do: select(Table, [t], {t.id, t.table})

  defp populate_table(table) do
    forwards = Repo.all(query())
    backwards = Enum.map(forwards, fn {x,y} -> {y,x} end)
    true = :ets.insert(table, forwards)
    true = :ets.insert(table, backwards)
  end

  defp query, do: select(Table, [t], {t.id, t.table})
end
