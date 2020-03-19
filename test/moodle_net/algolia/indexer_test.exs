# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Algolia.IndexerTest do
  use MoodleNet.DataCase
  alias MoodleNet.Algolia.Indexer
  import MoodleNet.Test.Faking

  test "format community" do
    community = fake_user!() |> fake_community!()
    json = Indexer.format_object(community)
    assert json["index_mothership_object_id"] == community.id
    assert json["canonicalUrl"] == community.actor.canonical_url
    assert json["icon"] == community.icon
    assert json["image"] == community.image
    assert json["preferredUsername"] == community.actor.preferred_username
    assert json["summary"] == community.summary
    assert json["index_type"] == "Community"
  end

  test "format collection" do
    user = fake_user!()
    community = fake_community!(user)
    collection = fake_collection!(user, community)

    json = Indexer.format_object(collection)
    assert json["index_mothership_object_id"] == collection.id
    assert json["canonicalUrl"] == collection.actor.canonical_url
    assert json["icon"] == collection.icon
    assert json["preferredUsername"] == collection.actor.preferred_username
    assert json["summary"] == collection.summary
    assert json["index_type"] == "Collection"
    assert is_map(json["community"])
  end

  test "format resource" do
    user = fake_user!()
    community = fake_community!(user)
    collection = fake_collection!(user, community)
    resource = fake_resource!(user, collection)

    json = Indexer.format_object(resource)
    assert json["index_mothership_object_id"] == resource.id
    assert json["canonicalUrl"] == resource.canonical_url
    assert json["icon"] == resource.icon
    assert json["summary"] == resource.summary
    assert json["index_type"] == "Resource"
    assert is_map(json["collection"])
    assert is_map(json["collection"]["community"])
  end
end
