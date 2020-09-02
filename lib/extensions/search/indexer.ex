# SPDX-License-Identifier: AGPL-3.0-only

defmodule CommonsPub.Search.Indexer do
  require Logger

  @public_index "public"

  def maybe_index_object(object) do
    indexable_object = format_object(object)

    if !is_nil(indexable_object) do
      index_for_search(indexable_object)
    else
      index_for_search(object)
    end
  end

  # add to general instance search index
  def index_object(objects) do
    # IO.inspect(search_indexing: objects)
    index_objects(objects, @public_index, true)
  end

  # index several things in an existing index
  def index_objects(objects, index_name, init_index_first \\ true)

  def index_objects(objects, index_name, init_index_first) when is_list(objects) do
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
  def init_index(index_name \\ "public", fail_silently \\ false)

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

  # def set_attributes(attrs, index) do
  #   settings(%{attributesForFaceting: attrs}, index)
  # end

  def set_facets(index_name, facets) when is_list(facets) do
    CommonsPub.Search.Meili.post(
      facets,
      index_name <> "/settings/attributes-for-faceting",
      true
    )
  end

  def set_facets(index_name, facet) do
    set_facets(index_name, [facet])
  end

  def list_facets(index_name \\ "public") do
    CommonsPub.Search.Meili.get(nil, index_name <> "/settings/attributes-for-faceting")
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

  def format_creator(%{creator: %{id: id}} = obj) when not is_nil(id) do
    creator = MoodleNetWeb.Helpers.Common.maybe_preload(obj, :creator).creator

    %{
      "id" => creator.id,
      "name" => creator.name,
      "username" => MoodleNet.Actors.display_username(creator),
      "canonical_url" => creator.actor.canonical_url
    }
  end

  def format_creator(_) do
    %{}
  end
end
