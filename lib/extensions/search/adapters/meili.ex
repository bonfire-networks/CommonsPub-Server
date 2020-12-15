# SPDX-License-Identifier: AGPL-3.0-only

defmodule Bonfire.Search.Meili do
  require Logger

  def search(%{} = params, index) when is_binary(index) do
    IO.inspect(search_params: params)

    with {:ok, req} <- api(:post, params, index <> "/search") do
      res = Jason.decode!(req.body)
      # IO.inspect(res)
      res
    else
      e ->
        Logger.error("Could not search Meili")
        Logger.debug(inspect(e))
        nil
    end
  end

  def index_exists(index_name) do
    with {:ok, _index} <- get(nil, index_name) do
      true
    else
      _e ->
        false
    end
  end

  def create_index(index_name, fail_silently \\ false) do
    post(%{uid: index_name}, "", fail_silently)
  end

  def list_facets(index_name \\ "public") do
    @adapter.get(nil, index_name <> "/settings/attributes-for-faceting")
  end

  def set_facets(index_name, facets) when is_list(facets) do
    post(
      facets,
      index_name <> "/settings/attributes-for-faceting",
      false
    )
  end

  def set_facets(index_name, facet) do
    set_facets(index_name, [facet])
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
           Bonfire.Search.HTTP.http_request(http_method, url, headers, object) do
      # IO.inspect(ret)
      {:ok, ret}
    else
      {_, message} ->
        Bonfire.Search.HTTP.http_error(fail_silently, http_method, message, object)
    end
  end
end
