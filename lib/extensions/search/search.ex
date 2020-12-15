# SPDX-License-Identifier: AGPL-3.0-only

defmodule Bonfire.Search do
  require Logger

  @public_index "public"
  @adapter Bonfire.Search.Meili # Application.get_env(:bonfire_search, :adapter)

  def search(string, index, calculate_facets, facets) when is_binary(string) and is_map(facets) do
    search(
      string,
      index,
      calculate_facets,
      facets
      |> Enum.map(&facet_from_map/1)
    )
  end

  def search(string, index, calculate_facets, facets)
      when is_binary(string) and is_list(facets) do
    object = %{
      q: string,
      facetFilters: List.flatten(facets)
    }

    search(object, index, calculate_facets)
  end

  def search(string, index, calculate_facets, _) do
    search(string, index, calculate_facets)
  end

  def search(string, index, calculate_facets)
      when is_list(calculate_facets) and is_binary(string) do
    object = %{
      q: string,
      facetsDistribution: calculate_facets
    }

    search(object, index)
  end

  def search(string, index, calculate_facets)
      when is_binary(calculate_facets) and is_binary(string) do
    search(string, index, [calculate_facets])
  end

  def search(params, index, _) do
    search(params, index)
  end

  def search(params, index \\ nil)

  def search(string, index) when is_binary(string) and is_binary(index) do
    object = %{
      q: string
    }

    search(object, index)
  end

  def search(object, index) when is_map(object) and is_binary(index) do
    @adapter.search(object, index)
  end

  def search(params, _) do
    search(params, @public_index)
  end

  def facet_from_map({key, values}) when is_list(values) do
    values
    |> Enum.map(&facet_from_map({key, &1}))
  end

  def facet_from_map({key, value}) when is_binary(value) do
    "#{key}:#{value}"
  end
end
