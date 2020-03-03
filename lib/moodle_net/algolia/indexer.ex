# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Algolia.Indexer do
  require Logger

  alias ActivityPub.HTTP
  alias MoodleNet.Repo
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Communities.Community
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Follows.FollowerCounts
  alias MoodleNet.Likes.LikerCounts

  defp check_envs() do
    System.get_env("ALGOLIA_ID") &&
      System.get_env("ALGOLIA_SECRET") &&
      System.get_env("ALGOLIA_INDEX")
  end

  defp supported_type(%Community{} = _object), do: true
  defp supported_type(%Collection{} = _object), do: true
  defp supported_type(%Resource{} = _object), do: true
  defp supported_type(_), do: false

  def maybe_index_object(object) do
    if check_envs() && supported_type(object) do
      object
      |> format_object()
      |> push_object()
    else
      :ok
    end
  end

  def format_object(%Community{} = community) do
    follower_count =
      case FollowerCounts.one(context_id: community.id) do
        {:ok, struct} -> struct.count
        {:error, _} -> nil
      end

    %{
      "index_mothership_object_id" => community.id,
      "canonicalUrl" => community.actor.canonical_url,
      "followers" => %{
        "totalCount" => follower_count
      },
      "icon" => Map.get(community, :icon),
      "image" => Map.get(community, :image),
      "name" => community.name,
      "preferredUsername" => community.actor.preferred_username,
      "summary" => Map.get(community, :summary),
      "index_type" => "Community",
      "index_instance" => System.get_env("HOSTNAME", MoodleNetWeb.Endpoint.host()),
      "createdAt" => community.published_at,
      "objectID" =>
        :crypto.hash(:sha, community.actor.canonical_url) |> Base.encode64(padding: false)
    }
  end

  def format_object(%Collection{} = collection) do
    collection = MoodleNet.Repo.preload(collection, community: [:actor])

    follower_count =
      case FollowerCounts.one(context_id: collection.id) do
        {:ok, struct} -> struct.count
        {:error, _} -> nil
      end

    %{
      "index_mothership_object_id" => collection.id,
      "canonicalUrl" => collection.actor.canonical_url,
      "followers" => %{
        "totalCount" => follower_count
      },
      "icon" => Map.get(collection, :icon),
      "name" => collection.name,
      "preferredUsername" => collection.actor.preferred_username,
      "summary" => Map.get(collection, :summary),
      "index_type" => "Collection",
      "index_instance" => System.get_env("HOSTNAME", MoodleNetWeb.Endpoint.host()),
      "createdAt" => collection.published_at,
      "community" => format_object(collection.community),
      "objectID" =>
        :crypto.hash(:sha, collection.actor.canonical_url) |> Base.encode64(padding: false)
    }
  end

  def format_object(%Resource{} = resource) do
    resource = Repo.preload(resource, collection: [actor: [], community: [actor: []]])

    likes_count =
      case LikerCounts.one(context_id: resource.id) do
        {:ok, struct} -> struct.count
        {:error, _} -> nil
      end

    %{
      "index_mothership_object_id" => resource.id,
      "name" => resource.name,
      "canonicalUrl" => resource.canonical_url,
      "createdAt" => resource.published_at,
      "icon" => Map.get(resource, :icon),
      "licence" => Map.get(resource, :licence),
      "likes" => %{
        "totalCount" => likes_count
      },
      "summary" => Map.get(resource, :summary),
      "updatedAt" => resource.updated_at,
      "index_type" => "Resource",
      "index_instance" => System.get_env("HOSTNAME", MoodleNetWeb.Endpoint.host()),
      "collection" => format_object(resource.collection),
      "objectID" => :crypto.hash(:sha, resource.canonical_url) |> Base.encode64(padding: false)
    }
  end

  def push_object(object) do
    json = Jason.encode!(object)
    application_id = System.get_env("ALGOLIA_ID")
    api_key = System.get_env("ALGOLIA_SECRET")
    index_name = System.get_env("ALGOLIA_INDEX")
    url = "https://#{application_id}.algolia.net/1/indexes/#{index_name}/#{object["objectID"]}"

    headers = [
      {"X-Algolia-API-Key", api_key},
      {"X-Algolia-Application-id", application_id}
    ]

    with {:ok, %{status: code}} when code == 200 <- HTTP.put(url, json, headers) do
      :ok
    else
      _ ->
        Logger.warn("Couldn't index object ID #{object["id"]}")
        :ok
    end
  end
end
