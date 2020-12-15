# SPDX-License-Identifier: AGPL-3.0-only

defmodule Bonfire.Search.Indexer do
  require Logger

  @public_index "public"
  # TODO: put in config
  @public_facets ["username", "index_type", "index_instance"]
  # Application.get_env(:bonfire_search, :adapter)
  @adapter Bonfire.Search.Meili

  def maybe_index_object(object) do
    indexable_object = maybe_indexable_object(object)

    if !is_nil(indexable_object) do
      index_public_object(indexable_object)
    end
  end

  def maybe_indexable_object(nil) do
    nil
  end

  def maybe_indexable_object(%{"index_type" => index_type} = object)
      when not is_nil(index_type) do
    # already formatted indexable object
    object
  end

  def maybe_indexable_object(%Pointers.Pointer{} = pointer) do
    pointed_object = Bonfire.Common.Pointers.follow!(pointer)
    maybe_indexable_object(pointed_object)
  end

  def maybe_indexable_object(%{__struct__: object_type} = object) do
    Bonfire.Contexts.run_context_function(
      object_type,
      :indexing_object_format,
      object
    )
  end


  def maybe_indexable_object(obj) do
    Logger.warn("Could not index object (not pre-formated for indexing or not a struct)")
    IO.inspect(obj)
    nil
  end

  # add to general instance search index
  def index_public_object(object) do
    # IO.inspect(search_indexing: objects)
    index_objects(object, @public_index, true)
  end

  # index several things in an existing index
  def index_objects(objects, index_name, init_index_first \\ true)

  def index_objects(objects, index_name, init_index_first) when is_list(objects) do
    # IO.inspect(objects)
    if System.get_env("SEARCH_INDEXING_DISABLED") != "true" do
      # FIXME - should create the index only once
      if init_index_first, do: init_index(index_name, true)
      @adapter.put(objects, index_name <> "/documents")
    end
  end

  # index something in an existing index
  def index_objects(object, index_name, init_index_first) do
    # IO.inspect(object)
    index_objects([object], index_name, init_index_first)
  end

  # create a new index
  def init_index(index_name \\ "public", fail_silently \\ false)

  def init_index("public" = index_name, fail_silently) do
    @adapter.create_index(index_name, fail_silently)

    # define facets to be used for filtering main search index
    @adapter.set_facets(index_name, @public_facets)
  end

  def init_index(index_name, fail_silently) do
    @adapter.create_index(index_name, fail_silently)
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
    # @adapter.delete(object_id)
  end

  def host(url) when is_binary(url) do
    URI.parse(url).host
  end

  def host(_) do
    ""
  end

  def format_creator(%{creator_id: id} = obj) when not is_nil(id) do
    creator = Bonfire.Repo.maybe_preload(obj, :creator) |> Map.get(:creator)

    format_creator(creator)
  end

  def format_creator(%Pointers.Pointer{} = pointer) do
    Bonfire.Common.Pointers.follow!(pointer) |> format_creator()
  end

  def format_creator(%{id: id} = creator) when not is_nil(id) do
    %{
      "id" => creator.id,
      "name" => creator.name
      # FIXME
      # "username" => CommonsPub.Characters.display_username(creator),
      # "canonical_url" => CommonsPub.ActivityPub.Utils.get_actor_canonical_url(creator)
    }
  end

  def format_creator(_) do
    nil
  end
end
