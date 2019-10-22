# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Localisation.CountryService do
  @moduledoc """
  An ets-based cache that allows lookup up Country objects by:

  * Database ID (string)

  On startup:
  * The database is queried for a list of countries
  * The data is inserted into an ets table owned by the process

  During operation, lookup requests will hit ets directly - this
  service exists solely to own the table and fit into the OTP
  supervision hierarchy neatly.
  """
  
  alias MoodleNet.Localisation.{Country, CountryNotFoundError}

  alias MoodleNet.Repo
  import Ecto.Query, only: [select: 3]

  use GenServer

  @init_query_name __MODULE__
  @service_name __MODULE__
  @table_name __MODULE__.Cache

  # public api

  @spec start_link() :: GenServer.on_start()
  @doc "Starts up the service registering it locally under this module's name"
  def start_link(),
    do: GenServer.start_link(__MODULE__, [name: @service_name])

  @spec lookup(iso2_code :: binary()) :: {:ok, Country.t} | {:error, CountryNotFoundError.t}
  @doc "Look up a Country by iso2 code"
  def lookup(key) when is_binary(key),
    do: lookup_result(key, :ets.lookup(@table_name, key))
	  
  defp lookup_result(key, []), do: {:error, CountryNotFoundError.new(key)}
  defp lookup_result(_, [{_,v}]), do: {:ok, v}

  @spec lookup!(iso2_code :: binary) :: Country.t
  @doc "Look up a Country by iso2 code, throw CountryNotFoundError if not found"
  def lookup!(key) do
    case lookup(key) do
      {:ok, v} -> v
      {:error, reason} -> throw reason
    end
  end

  @spec lookup_id(iso2_code :: binary) :: {:ok, binary} | {:error, CountryNotFoundError.t}
  @doc "Look up a country id by iso2 code"
  def lookup_id(key) do
    with {:ok, val} <- lookup(key), do: {:ok, val.id}
  end

  @spec lookup_id!(iso2_code :: binary) :: binary
  @doc "Look up a country id by iso2 code, throw CountryNotFoundError if not found"
  def lookup_id!(key) do
    case lookup_id(key) do
      {:ok, v} -> v
      {:error, reason} -> throw reason
    end
  end

  # callbacks

  @doc false
  def init(_) do
    Country
    |> Repo.all(telemetry_event: @init_query_name)
    |> populate_countries()
    {:ok, []}
  end

  defp populate_countries(entries) do
    :ets.new(@table_name, [:named_table])
    indexed = Enum.map(entries, &({&1.id, &1}))
    true = :ets.insert(@table_name, indexed)
  end

end
