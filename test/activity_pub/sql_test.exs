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
      assert {:ok, persisted_entity} = SQL.persist(entity)
      assert load_entity = SQL.load(persisted_entity.local_id)
      assert load_entity == persisted_entity
    end

    test "set URLs" do
      map = %{
        "@context": "https://www.w3.org/ns/activitystreams",
        type: "Person",
        name: "Alex",
        preferredUsername: "alex",
      }

      assert {:ok, entity} = Entity.parse(map)
      assert {:ok, persisted_entity} = SQL.persist(entity) |> IO.inspect()
      assert persisted_entity[:id]
      assert persisted_entity[:followers]
      assert persisted_entity[:following]
      assert persisted_entity[:liked]
      assert persisted_entity[:inbox]
      assert persisted_entity[:outbox]
    end

    test "persist assocs" do
      map = %{
        type: "Note",
        content: "My content",
        attributed_to: %{
          type: "Person",
          name: "Alex",
          preferredUsername: "alexcastano"
        }
      }

      assert {:ok, note} = Entity.parse(map)
      assert {:ok, persisted_note} = SQL.persist(note) |> IO.inspect()
      assert persisted_note[:content] == %{"und" => map[:content]}
      assert [persisted_person] = persisted_note[:attributed_to]
      assert persisted_person[:name] == %{"und" => "Alex"}

      assert {:ok, loaded_note} = SQL.load(persisted_note.local_id)
      assert loaded_note[:content] == %{"und" => map[:content]}

      assert loaded_note[:attributed_to] == []
      loaded_note = SQL.preload(loaded_note, :attributed_to)
      assert [loaded_person] = loaded_note[:attributed_to]
      assert loaded_person[:name] == %{"und" => "Alex"}
    end
  end
end
