# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule CommonsPub.Search.Indexer do
  require Logger

  @public_index "public"

  def maybe_index_object(object) do
    indexable_object = format_object(object)

    if !is_nil(indexable_object) do
      index_object(indexable_object)
    else
      thing_name = object.__struct__

      if(
        !is_nil(thing_name) and
          Kernel.function_exported?(thing_name, :context_module, 0)
      ) do
        thing_context_module = apply(thing_name, :context_module, [])

        if(Kernel.function_exported?(thing_context_module, :format_object, 1)) do
          # IO.inspect(function_exists_in: thing_context_module)
          indexable_object = apply(thing_context_module, :format_object, [object])
          index_object(indexable_object)
        else
          Logger.info(
            "Could not index #{thing_name} object (no context module with format_object/1)"
          )
        end
      else
        Logger.info("Could not index #{thing_name} object (no known context module)")
      end
    end
  end

  # add to general instance search index
  def index_object(objects) do
    IO.inspect(search_indexing: objects)
    index_objects(objects, @public_index, true)
  end

  # index several things in an existing index
  defp index_objects(objects, index_name, create_index_first \\ true) when is_list(objects) do
    # IO.inspect(objects)
    # FIXME - should create the index only once
    if create_index_first, do: create_index(index_name, true)
    CommonsPub.Search.Meili.put(objects, "/" <> index_name <> "/documents")
  end

  # index something in an existing index
  defp index_objects(object, index_name, create_index_first) do
    # IO.inspect(object)
    index_objects([object], index_name, create_index_first)
  end

  # create a new index
  def create_index(index_name, fail_silently \\ false) do
    CommonsPub.Search.Meili.post(%{uid: index_name}, "", fail_silently)
  end

  def maybe_delete_object(object) do
    delete_object(object)
    :ok
  end

  defp delete_object(nil) do
    Logger.warn("Couldn't get object ID in order to delete")
  end

  defp delete_object(object_id) do
    # TODO
  end

  def format_object(%MoodleNet.Communities.Community{} = community) do
    follower_count =
      case MoodleNet.Follows.FollowerCounts.one(context: community.id) do
        {:ok, struct} -> struct.count
        {:error, _} -> nil
      end

    icon = MoodleNet.Uploads.remote_url_from_id(community.icon_id)
    image = MoodleNet.Uploads.remote_url_from_id(community.image_id)
    url = MoodleNet.ActivityPub.Utils.get_actor_canonical_url(community)

    %{
      "id" => community.id,
      "canonicalUrl" => url,
      "followers" => %{
        "totalCount" => follower_count
      },
      "icon" => icon,
      "image" => image,
      "name" => community.name,
      "preferredUsername" => community.actor.preferred_username,
      "summary" => Map.get(community, :summary),
      "index_type" => "MoodleNet.Communities.Community",
      "index_instance" => URI.parse(url).host,
      "createdAt" => community.published_at
    }
  end

  def format_object(%MoodleNet.Collections.Collection{} = collection) do
    collection = MoodleNet.Repo.preload(collection, community: [:actor])

    follower_count =
      case MoodleNet.Follows.FollowerCounts.one(context: collection.id) do
        {:ok, struct} -> struct.count
        {:error, _} -> nil
      end

    icon = MoodleNet.Uploads.remote_url_from_id(collection.icon_id)
    url = MoodleNet.ActivityPub.Utils.get_actor_canonical_url(collection)

    %{
      "id" => collection.id,
      "canonicalUrl" => url,
      "followers" => %{
        "totalCount" => follower_count
      },
      "icon" => icon,
      "name" => collection.name,
      "preferredUsername" => collection.actor.preferred_username,
      "summary" => Map.get(collection, :summary),
      "index_type" => "MoodleNet.Collections.Collection",
      "index_instance" => URI.parse(url).host,
      "createdAt" => collection.published_at,
      "community" => format_object(collection.community)
    }
  end

  def format_object(%MoodleNet.Resources.Resource{} = resource) do
    resource =
      MoodleNet.Repo.preload(resource,
        collection: [actor: [], community: [actor: []]],
        content: []
      )

    likes_count =
      case MoodleNet.Likes.LikerCounts.one(context: resource.id) do
        {:ok, struct} -> struct.count
        {:error, _} -> nil
      end

    icon = MoodleNet.Uploads.remote_url_from_id(resource.icon_id)
    resource_url = MoodleNet.Uploads.remote_url_from_id(resource.content_id)

    canonical_url = MoodleNet.ActivityPub.Utils.get_object_canonical_url(resource)

    %{
      "id" => resource.id,
      "name" => resource.name,
      "canonicalUrl" => canonical_url,
      "createdAt" => resource.published_at,
      "icon" => icon,
      "licence" => Map.get(resource, :license),
      "likes" => %{
        "totalCount" => likes_count
      },
      "summary" => Map.get(resource, :summary),
      "updatedAt" => resource.updated_at,
      "index_type" => "MoodleNet.Resources.Resource",
      "index_instance" => URI.parse(canonical_url).host,
      "collection" => format_object(resource.collection),
      "url" => resource_url,
      "author" => Map.get(resource, :author),
      "mediaType" => resource.content.media_type,
      "subject" => Map.get(resource, :subject),
      "level" => Map.get(resource, :level),
      "language" => Map.get(resource, :language)
    }
  end

  def format_object(_) do
    nil
  end
end
