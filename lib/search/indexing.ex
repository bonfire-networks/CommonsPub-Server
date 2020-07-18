# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Search.Indexing do
  require Logger

  # alias ActivityPub.HTTP

  @public_index "public"

  # create a new index
  def create_index(index_name) do
    Search.Meili.post(%{uid: index_name})
  end

  # index something coming in via old Algolia indexing module
  def maybe_index_object(%{"index_mothership_object_id" => _} = object) do
    index_for_search(Map.put(object, "id", object["index_mothership_object_id"]))
  end

  # index something with an unspecified index
  def maybe_index_object(object) do
    index_for_search(object)
  end

  # add to general instance search index
  def index_for_search(object) do
    IO.inspect(search_indexing: object)
    index_object(object, @public_index, true)
  end

  # index something in an existing index
  def index_object(object, index_name, create_index_first \\ true) do
    # IO.inspect(object)
    index_objects([object], index_name, create_index_first)
  end

  # index several things in an existing index
  def index_objects(objects, index_name, create_index_first \\ true) do
    # IO.inspect(objects)
    # FIXME - should create the index only once
    if create_index_first, do: create_index(index_name)
    Search.Meili.put(objects, "/" <> index_name <> "/documents")
  end
end
