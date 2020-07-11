# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Search.Meili do
  require Logger

  alias ActivityPub.HTTP

  def search(%{} = object, index_path) do
    {:ok, req} = api(:get, object, index_path)
    res = Jason.decode!(req.body)
    # IO.inspect(res)
    res
  end

  def search(string, index_path) do
    object = %{
      q: string
    }

    search(object, index_path)
  end

  def search(string) do
    search(string, "/search/search")
  end

  def push_object(object) do
    push_object(object, "")
  end

  def push_object(object, index_path) do
    api(:put, object, index_path)
  end

  def api(http_method, object, index_path) do
    search_instance = System.get_env("SEARCH_MEILI_INSTANCE", "search:7700")
    api_key = System.get_env("SEARCH_MEILI_SECRET")

    url = "http://#{search_instance}/indexes" <> index_path

    # if api_key do
    headers = [
      {"X-Meili-API-Key", api_key}
    ]

    # else
    #   headers = [] #FIXME
    # end

    with {:ok, %{status: code} = ret} when code == 200 or code == 201 or code == 202 <-
           http_request(http_method, url, headers, object) do
      IO.inspect(ret)
      {:ok, ret}
    else
      {_, message} ->
        Logger.warn("Couldn't #{http_method} objects:")
        Logger.warn(inspect(object))
        Logger.warn(inspect(message))
        :ok
    end
  end

  def http_request(http_method, url, headers, object) do
    if(http_method == :get) do
      query_str = URI.encode_query(object)
      get_url = url <> "?" <> query_str
      apply(HTTP, http_method, [get_url, headers])
    else
      json = Jason.encode!(object)
      apply(HTTP, http_method, [url, json, headers])
    end
  end
end
