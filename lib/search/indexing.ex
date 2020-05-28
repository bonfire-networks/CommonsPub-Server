# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Search.Indexing do
    require Logger
  
    alias ActivityPub.HTTP

    # create a new index
    def create_index(index_name) do
        push_object(%{ uid: index_name})
    end

    # index something in an unknown index
    def maybe_index_object(object) do
      IO.inspect(object)
      # index_objects([object], index_name)
    end

    # index something in an existing index
    def index_object(object, index_name) do
        index_objects([object], index_name)
    end

    # index several things in an existing index
    def index_objects(object, index_name) do
        create_index(index_name) # FIXME - should create the index only once
        push_object(object, "/"<>index_name<>"/documents")
    end

    defp push_object(object) do
        push_object(object, "")
    end
  
    defp push_object(object, index_path) do
            
      search_instance = System.get_env("SEARCH_MEILI_INSTANCE", "search:7700")
      api_key = System.get_env("SEARCH_MEILI_SECRET")

      url = "http://#{search_instance}/indexes"<>index_path

      if api_key do
        headers = [
          {"X-Meili-API-Key", api_key},
        ]
      end

      json = Jason.encode!(object)
  
      with {:ok, %{status: code}} when code == 200 or code == 201 or code == 202 <- HTTP.post(url, json, headers) do
        :ok
      else
        {_, message} ->
          Logger.warn("Couldn't index objects:")
          Logger.warn(inspect(object))
          Logger.warn(inspect(message))
          :ok
      end
    end
  

  end
  