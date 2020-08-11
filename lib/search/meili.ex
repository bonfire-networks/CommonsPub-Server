# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Search.Meili do
  require Logger

  alias ActivityPub.HTTP

  @public_index "public"

  def search(string_or_params) do
    search(string_or_params, @public_index)
  end

  def search(%{} = params, index_path) do
    {:ok, req} = api(:get, params, index_path)
    res = Jason.decode!(req.body)
    # IO.inspect(res)
    res
  end

  def search(string, index) do
    object = %{
      q: string
    }

    search(object, "/" <> index <> "/search")
  end

  def put(object) do
    put(object, "")
  end

  def put(object, index_path) do
    api(:put, object, index_path)
  end

  def settings(object, index) do
    post(object, "/" <> index <> "/settings")
  end

  def set_attributes(attrs, index) do
    settings(%{attributesForFaceting: attrs}, index)
  end

  def post(object) do
    post(object, "")
  end

  def post(object, index_path, fail_silently \\ false) do
    api(:post, object, index_path, fail_silently)
  end

  def api(http_method, object, index_path, fail_silently \\ false) do
    search_instance = System.get_env("SEARCH_MEILI_INSTANCE", "localhost:7700")
    api_key = System.get_env("MEILI_MASTER_KEY")

    url = "http://#{search_instance}/indexes" <> index_path

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
        if(fail_silently) do
          # Logger.info("Meili - Couldn't #{http_method} object")
          # Logger.info(inspect(object))
          :ok
        else
          Logger.error("Meili - Couldn't #{http_method} objects:")
          Logger.warn(inspect(object))
          Logger.warn(inspect(message))
          {:error, message}
        end
    end
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
