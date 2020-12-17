# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Pointers.Tables do
  alias Pointers.Table
  alias Bonfire.Repo.Introspection

  import Bonfire.Common.Config, only: [repo: 0]
  @init_query_name __MODULE__

  def fetch_list() do
    Table
    |> repo().all(telemetry_event: @init_query_name)
    # |> IO.inspect
    |> pair_schemata()
  end

  # Loops over entries, adding the module name of an Ecto Schema
  # operating over the referenced tables to the `schema` key. Errors
  # if a matching schema is not found
  def pair_schemata(entries) do
    schema_modules = Introspection.ecto_schema_modules()
    # IO.inspect(schema_modules: schema_modules)
    index =
      Enum.reduce(schema_modules, %{}, fn module, acc ->
        schema_reduce(Introspection.ecto_schema_table(module), module, acc)
      end)

    Enum.reduce(entries, [], &pair_schema(&1, Map.get(index, &1.table), &2))
  end

  # Drop an entry where the table does not exist
  defp schema_reduce(nil, _, acc), do: acc
  defp schema_reduce(table, module, acc), do: Map.put(acc, table, module)

  # Error if there was no matching schema, otherwise add it to the entry
  defp pair_schema(_entry, nil, acc), do: acc

  # uncomment the following line if you want to auto-remove defunct tables from your meta table
  # CommonsPub.ReleaseTasks.remove_meta_table(entry.table)
  # throw {:missing_schema, entry.table}
  # end

  defp pair_schema(entry, schema, acc), do: [%{entry | schema: schema} | acc]
end
