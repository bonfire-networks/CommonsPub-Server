# SPDX-License-Identifier: AGPL-3.0-only

defmodule CommonsPub.Search.Indexer do
  require Logger

  @public_index "public"

  def maybe_index_object(object) do
    indexable_object = indexing_object_format(object)

    if !is_nil(indexable_object) do
      index_object(indexable_object)
    else
      thing_name = object.__struct__

      if(
        !is_nil(thing_name) and
          Kernel.function_exported?(thing_name, :context_module, 0)
      ) do
        thing_context_module = apply(thing_name, :context_module, [])

        if(Kernel.function_exported?(thing_context_module, :indexing_object_format, 1)) do
          # IO.inspect(function_exists_in: thing_context_module)
          indexable_object = apply(thing_context_module, :indexing_object_format, [object])
          index_object(indexable_object)
        else
          Logger.info(
            "Could not index #{thing_name} object (no context module with indexing_object_format/1)"
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
  def index_objects(objects, index_name, init_index_first \\ true)

  def index_objects(objects, index_name, init_index_first) when is_list(objects) do
    # IO.inspect(objects)
    # FIXME - should create the index only once
    if init_index_first, do: init_index(index_name, true)
    CommonsPub.Search.Meili.put(objects, index_name <> "/documents")
  end

  # index something in an existing index
  def index_objects(object, index_name, init_index_first) do
    # IO.inspect(object)
    index_objects([object], index_name, init_index_first)
  end

  # create a new index
  def init_index(index_name, fail_silently \\ false)

  def init_index("public" = index_name, fail_silently) do
    create_index(index_name, fail_silently)
    set_facets(index_name, ["username", "index_type", "index_instance"])
  end

  def init_index(index_name, fail_silently) do
    create_index(index_name, fail_silently)
  end

  def create_index(index_name, fail_silently \\ false) do
    CommonsPub.Search.Meili.post(%{uid: index_name}, "", fail_silently)
  end

  def index_exists(index_name) do
    with {:ok, _index} <- CommonsPub.Search.Meili.get(nil, index_name) do
      true
    else
      _e ->
        false
    end
  end

  def set_facets(index_name, facets) when is_list(facets) do
    CommonsPub.Search.Meili.post(
      facets,
      index_name <> "/settings/attributes-for-faceting"
    )
  end

  def set_facets(index_name, facet) do
    set_facets(index_name, [facet])
  end

  def maybe_delete_object(object) do
    delete_object(object)
    :ok
  end

  defp delete_object(nil) do
    Logger.warn("Couldn't get object ID in order to delete")
  end

  defp delete_object(_object_id) do
    # TODO
  end

  def indexing_object_format(%MoodleNet.Users.User{} = user) do
    follower_count =
      case MoodleNet.Follows.FollowerCounts.one(context: user.id) do
        {:ok, struct} -> struct.count
        {:error, _} -> nil
      end

    icon = MoodleNet.Uploads.remote_url_from_id(user.icon_id)
    image = MoodleNet.Uploads.remote_url_from_id(user.image_id)
    url = MoodleNet.ActivityPub.Utils.get_actor_canonical_url(user)

    %{
      "id" => user.id,
      "canonical_url" => url,
      "followers" => %{
        "total_count" => follower_count
      },
      "icon" => icon,
      "image" => image,
      "name" => user.name,
      "username" => MoodleNet.Actors.display_username(user),
      "summary" => Map.get(user, :summary),
      "index_type" => "User",
      "index_instance" => URI.parse(url).host,
      "published_at" => user.published_at
    }
  end

  def indexing_object_format(%MoodleNet.Communities.Community{} = community) do
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
      "canonical_url" => url,
      "followers" => %{
        "total_count" => follower_count
      },
      "icon" => icon,
      "image" => image,
      "name" => community.name,
      "username" => MoodleNet.Actors.display_username(community),
      "summary" => Map.get(community, :summary),
      "index_type" => "Community",
      "index_instance" => URI.parse(url).host,
      "published_at" => community.published_at
    }
  end

  def indexing_object_format(%MoodleNet.Collections.Collection{} = collection) do
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
      "canonical_url" => url,
      "followers" => %{
        "total_count" => follower_count
      },
      "icon" => icon,
      "name" => collection.name,
      "username" => MoodleNet.Actors.display_username(collection),
      "summary" => Map.get(collection, :summary),
      "index_type" => "Collection",
      "index_instance" => URI.parse(url).host,
      "published_at" => collection.published_at,
      "community" => indexing_object_format(collection.community)
    }
  end

  def indexing_object_format(%MoodleNet.Resources.Resource{} = resource) do
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
      "canonical_url" => canonical_url,
      "created_at" => resource.published_at,
      "icon" => icon,
      "licence" => Map.get(resource, :license),
      "likes" => %{
        "total_count" => likes_count
      },
      "summary" => Map.get(resource, :summary),
      "updated_at" => resource.updated_at,
      "index_type" => "Resource",
      "index_instance" => URI.parse(canonical_url).host,
      "collection" => indexing_object_format(resource.collection),
      "url" => resource_url,
      "author" => Map.get(resource, :author),
      "media_type" => resource.content.media_type,
      "subject" => Map.get(resource, :subject),
      "level" => Map.get(resource, :level),
      "language" => Map.get(resource, :language)
    }
  end

  def indexing_object_format(_) do
    nil
  end
end
