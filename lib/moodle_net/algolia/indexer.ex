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

  def index_object(object) do
    object
    |> format_object()
    |> push_object()
  end

  def format_object(%Community{} = community) do
    follower_count =
      case FollowerCounts.one(context_id: community.id) do
        {:ok, struct} -> struct.count
        {:error, _} -> nil
      end

    %{
      "id" => community.id,
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
      "createdAt" => community.published_at
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
      "id" => collection.id,
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
      "community" => format_object(collection.community)
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
      "id" => resource.id,
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
      "collection" => format_object(resource.collection)
    }
  end

  def push_object(object) do
    json = Jason.encode!(object)
    application_id = System.get_env("ALGOLIA_ID")
    api_key = System.get_env("ALGOLIA_SECRET")
    index_name = System.get_env("ALGOLIA_INDEX")
    url = "https://#{application_id}.algolia.net/1/indexes/#{index_name}"

    headers = [
      {"X-Algolia-API-Key", api_key},
      {"X-Algolia-Application-id", application_id}
    ]

    with {:ok, %{status: code}} when code == 201 <- HTTP.post(url, json, headers) do
      :ok
    else
      _ -> Logger.warn("Couldn't index object ID #{object["id"]}")
    end
  end
end
