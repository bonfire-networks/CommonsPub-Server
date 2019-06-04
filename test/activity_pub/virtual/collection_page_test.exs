# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.CollectionPageTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.CollectionPage

  test "works" do
    actor = Factory.actor()
    community = Factory.community(actor)
    actor_4 = Factory.actor()
    actor_3 = Factory.actor()
    actor_2 = Factory.actor()
    MoodleNet.join_community(actor_2, community)
    MoodleNet.join_community(actor_3, community)
    MoodleNet.join_community(actor_4, community)

    assert {:ok, page} = CollectionPage.new(community.followers)
    assert page["next"] == nil
    assert page["prev"] == nil
    assert page.total_items == 4
    assert length(page.items) == 4
    assert page["part_of"] == community.followers
    assert [actor_4.id, actor_3.id, actor_2.id, actor.id] == Enum.map(page.items, & &1.id)

    followers_id = community.followers.id

    assert {:ok, page} = CollectionPage.new(community.followers, %{"limit" => 1})
    assert String.starts_with?(page["next"], followers_id <> "/page?")
    assert page["prev"] == nil
    assert page.total_items == 1
    assert length(page.items) == 1
    assert page["part_of"] == community.followers
    assert [actor_4.id] == Enum.map(page.items, & &1.id)

    query = URI.parse(page["next"]) |> Map.get(:query) |> URI.decode_query() |> Map.put("limit", 1)

    assert {:ok, page} = CollectionPage.new(community.followers, query)
    assert String.starts_with?(page["next"], followers_id <> "/page?")
    assert page["prev"]
    assert page.total_items == 1
    assert length(page.items) == 1
    assert page["part_of"] == community.followers
    assert [actor_3.id] == Enum.map(page.items, & &1.id)

    query = URI.parse(page["next"]) |> Map.get(:query) |> URI.decode_query() |> Map.put("limit", 1)

    assert {:ok, page} = CollectionPage.new(community.followers, query)
    assert String.starts_with?(page["next"], followers_id <> "/page?")
    assert page["prev"]
    assert page.total_items == 1
    assert length(page.items) == 1
    assert page["part_of"] == community.followers
    assert [actor_2.id] == Enum.map(page.items, & &1.id)

    query = URI.parse(page["next"]) |> Map.get(:query) |> URI.decode_query() |> Map.put("limit", 1)

    assert {:ok, page} = CollectionPage.new(community.followers, query)
    assert String.starts_with?(page["next"], followers_id <> "/page?")
    assert page["prev"]
    assert page.total_items == 1
    assert length(page.items) == 1
    assert page["part_of"] == community.followers
    assert [actor.id] == Enum.map(page.items, & &1.id)

    query = URI.parse(page["next"]) |> Map.get(:query) |> URI.decode_query() |> Map.put("limit", 1)

    assert {:ok, page} = CollectionPage.new(community.followers, query)
    assert page["next"] == nil
    assert String.starts_with?(page["prev"], followers_id <> "/page?")
    assert page.total_items == 0
    assert page.items == []
    assert page["part_of"] == community.followers

    query = URI.parse(page["prev"]) |> Map.get(:query) |> URI.decode_query() |> Map.put("limit", 1)

    assert {:ok, page} = CollectionPage.new(community.followers, query)
    assert page["next"]
    assert String.starts_with?(page["prev"], followers_id <> "/page?")
    assert page.total_items == 1
    assert length(page.items) == 1
    assert page["part_of"] == community.followers
    assert [actor.id] == Enum.map(page.items, & &1.id)

    query = URI.parse(page["prev"]) |> Map.get(:query) |> URI.decode_query() |> Map.put("limit", 1)

    assert {:ok, page} = CollectionPage.new(community.followers, query)
    assert page["next"]
    assert String.starts_with?(page["prev"], followers_id <> "/page?")
    assert page.total_items == 1
    assert length(page.items) == 1
    assert page["part_of"] == community.followers
    assert [actor_2.id] == Enum.map(page.items, & &1.id)

    query = URI.parse(page["prev"]) |> Map.get(:query) |> URI.decode_query() |> Map.put("limit", 1)

    assert {:ok, page} = CollectionPage.new(community.followers, query)
    assert page["next"]
    assert String.starts_with?(page["prev"], followers_id <> "/page?")
    assert page.total_items == 1
    assert length(page.items) == 1
    assert page["part_of"] == community.followers
    assert [actor_3.id] == Enum.map(page.items, & &1.id)

    query = URI.parse(page["prev"]) |> Map.get(:query) |> URI.decode_query() |> Map.put("limit", 1)

    assert {:ok, page} = CollectionPage.new(community.followers, query)
    assert page["next"]
    assert String.starts_with?(page["prev"], followers_id <> "/page?")
    assert page.total_items == 1
    assert length(page.items) == 1
    assert page["part_of"] == community.followers
    assert [actor_4.id] == Enum.map(page.items, & &1.id)

    query = URI.parse(page["prev"]) |> Map.get(:query) |> URI.decode_query() |> Map.put("limit", 1)

    assert {:ok, page} = CollectionPage.new(community.followers, query)
    assert page["next"]
    assert page["prev"] == nil
    assert page.total_items == 0
    assert page.items == []
    assert page["part_of"] == community.followers
  end
end
