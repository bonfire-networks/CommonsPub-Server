# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Localisation.LanguageService do
  @moduledoc """
  An ets-based cache that allows lookup up Language objects by:

  * Database ID (string)

  On startup:
  * The database is queried for a list of languages
  * The data is inserted into an ets table owned by the process

  During operation, lookup requests will hit ets directly - this
  service exists solely to own the table and fit into the OTP
  supervision hierarchy neatly.
  """
  
  alias MoodleNet.Localisation.{Language, LanguageNotFoundError}

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

  @doc "Lists all languages we know"
  @spec list_all() :: [ Language.t ]
  def list_all() do
    case :ets.lookup(@table_name, :ALL) do
      [{_,r}] -> r
      _ -> []
    end
  end

  @spec lookup(iso2_code :: binary()) :: {:ok, Language.t} | {:error, LanguageNotFoundError.t}
  @doc "Look up a Language by iso2 code"
  def lookup(key) when is_binary(key),
    do: lookup_result(key, :ets.lookup(@table_name, key))
	  
  defp lookup_result(_key, []), do: {:error, LanguageNotFoundError.new()}
  defp lookup_result(_, [{_,v}]), do: {:ok, v}

  @spec lookup!(iso2_code :: binary) :: Language.t
  @doc "Look up a Language by iso2 code, throw LanguageNotFoundError if not found"
  def lookup!(key) do
    case lookup(key) do
      {:ok, v} -> v
      {:error, reason} -> throw reason
    end
  end

  @spec lookup_id(iso2_code :: binary) :: {:ok, binary} | {:error, LanguageNotFoundError.t}
  @doc "Look up a language id by iso2 code"
  def lookup_id(key) do
    with {:ok, val} <- lookup(key), do: {:ok, val.id}
  end

  @spec lookup_id!(iso2_code :: binary) :: binary
  @doc "Look up a language id by iso2 code, throw LanguageNotFoundError if not found"
  def lookup_id!(key) do
    case lookup_id(key) do
      {:ok, v} -> v
      {:error, reason} -> throw reason
    end
  end

  # callbacks

  @doc false
  def init(_) do
    Language
    |> Repo.all(telemetry_event: @init_query_name)
    |> populate_languages()
    {:ok, []}
  end

  defp populate_languages(entries) do
    :ets.new(@table_name, [:named_table])
    all = {:ALL, entries} # to enable list queries
    indexed = Enum.flat_map(entries, fn lang ->
      [ {lang.id, lang},
	{lang.iso_code2, lang},
	{lang.iso_code3, lang} ]
    end)
    true = :ets.insert(@table_name, [all | indexed])
  end

  import Ecto.Query, only: [from: 2]

  # defp q() do
  #   from l in Language, order_by: [asc: l.id]
  # end

end
