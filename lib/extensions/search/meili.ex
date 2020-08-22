# SPDX-License-Identifier: AGPL-3.0-only

defmodule CommonsPub.Search.Meili do
  require Logger

  alias ActivityPub.HTTP

  @public_index "public"

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
      facetFilters: facets
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
    search_meili(object, index)
  end

  def search(params, _) do
    search(params, @public_index)
  end

  def search_meili(%{} = params, index) when is_binary(index) do
    {:ok, req} = api(:post, params, index <> "/search")
    res = Jason.decode!(req.body)
    # IO.inspect(res)
    res
  end

  def facet_from_map({key, values}) when is_list(values) do
    values
    |> Enum.map(&facet_from_map({key, &1}))
  end

  def facet_from_map({key, value}) when is_binary(value) do
    "#{key}:#{value}"
  end

  def get(object) do
    get(object, "")
  end

  def get(object, index_path, fail_silently \\ false) do
    api(:get, object, index_path, fail_silently)
  end

  def post(object) do
    post(object, "")
  end

  def post(object, index_path, fail_silently \\ false) do
    api(:post, object, index_path, fail_silently)
  end

  def put(object) do
    put(object, "")
  end

  def put(object, index_path, fail_silently \\ false) do
    api(:put, object, index_path, fail_silently)
  end

  def settings(object, index) do
    post(object, index <> "/settings")
  end

  def set_attributes(attrs, index) do
    settings(%{attributesForFaceting: attrs}, index)
  end

  def api(http_method, object, index_path, fail_silently \\ false) do
    search_instance = System.get_env("SEARCH_MEILI_INSTANCE", "localhost:7700")
    api_key = System.get_env("MEILI_MASTER_KEY")

    url = "http://#{search_instance}/indexes/" <> index_path

    # if api_key do
    headers = [
      {"X-Meili-API-Key", api_key},
      {"Content-type", "application/json"}
    ]

    # else
    #   headers = [] #FIXME
    # end

    with {:ok, %{status: code} = ret} when code == 200 or code == 201 or code == 202 <-
           http_request(http_method, url, headers, object) do
      # IO.inspect(ret)
      {:ok, ret}
    else
      {_, message} ->
        http_error(http_method, message, object)
    end
  end

  if Mix.env() == :test do
    def http_error(http_method, _message, _object) do
      Logger.info("Meili - Could not #{http_method} objects")
    end
  else
    def http_error(http_method, message, object) do
      if(fail_silently) do
        Logger.info("Meili - Could not #{http_method} object")
        # Logger.info(inspect(object))
        :ok
      else
        Logger.error("Meili - Couldn't #{http_method} objects:")
        Logger.warn(inspect(message))
        Logger.info(inspect(object))
        {:error, message}
      end
    end
  end

  def http_request(http_method, url, headers, nil) do
    http_request(http_method, url, headers, %{})
  end

  def http_request(http_method, url, headers, object) do
    if(http_method == :get) do
      query_str = URI.encode_query(object)
      get_url = url <> "?" <> query_str
      apply(HTTP, http_method, [get_url, headers])
    else
      # IO.inspect(object)
      json = Jason.encode!(object)
      # IO.inspect(json: json)
      apply(HTTP, http_method, [url, json, headers])
    end
  end
end
