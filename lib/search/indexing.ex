# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Search.Indexing do
  require Logger

  alias ActivityPub.HTTP

  # create a new index
  def create_index(index_name) do
    Search.Meili.push_object(%{uid: index_name})
  end

  # index something coming from old Algolia indexer
  def maybe_index_object(%{"index_mothership_object_id" => _} = object) do
    index_for_search(Map.put(object, "id", object["index_mothership_object_id"]))
  end

  # index something with an unspecified index
  def maybe_index_object(object) do
    index_for_search(object)
  end

  # add to general instance search index
  def index_for_search(object) do
    # IO.inspect(object)
    index_object(object, "search")
  end

  # index something in an existing index
  def index_object(object, index_name) do
    index_objects([object], index_name)
  end

  # index several things in an existing index
  def index_objects(object, index_name) do
    # FIXME - should create the index only once
    create_index(index_name)
    Search.Meili.push_object(object, "/" <> index_name <> "/documents")
  end
end
