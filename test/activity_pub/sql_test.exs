defmodule ActivityPub.SQLTest do
  use MoodleNet.DataCase, async: true

  doctest ActivityPub.SQL

  alias ActivityPub.Entity
  alias ActivityPub.SQL

  describe "persist" do
    test "works" do
      map = %{
        "@context": ["https://www.w3.org/ns/activitystreams", %{"@language": "ja"}],
        type: "Person",
        id: "https://kenzoishii.example.com/",
        name: "石井健蔵",
        summary: "この方はただの例です",
        following: "https://kenzoishii.example.com/following.json",
        followers: "https://kenzoishii.example.com/followers.json",
        liked: "https://kenzoishii.example.com/liked.json",
        inbox: "https://kenzoishii.example.com/inbox.json",
        outbox: "https://kenzoishii.example.com/feed.json",
        preferredUsername: "kenzoishii",
        new_field: "extra",
      }

      assert {:ok, entity} = Entity.parse(map)
      assert {:ok, persisted_entity} = SQL.persist(entity) |> IO.inspect()
      assert load_entity = SQL.load(persisted_entity.local_id) |> IO.inspect()
    end
  end
end
