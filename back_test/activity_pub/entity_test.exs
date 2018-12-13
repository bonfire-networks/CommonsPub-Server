defmodule ActivityPub.EntityTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.Entity

  describe "parse" do
    test "simple objects" do
      map = %{
        attributed_to: [
          %{
            id: "https://alex.gitlab.com",
            type: "Person",
            name: "Alex",
            inbox: "https://alex.gitlab.com/inbox",
            outbox: "https://alex.gitlab.com/outbox"
          },
          "https://doug.gitlab.com"
        ],
        type: "Object",
        content: "This is a content",
        name: "This is my name",
        end_time: "2015-01-01T06:00:00-08:00",
        new_field: "extra",
        url: "https://alex.gitlab.com/profile"
      }

      assert {:ok, entity} = Entity.parse(map)
      assert entity[:content] == %{"und" => map.content}
      assert entity[:name] == %{"und" => map.name}
      assert entity["content"] == %{"und" => map.content}
      assert entity["name"] == %{"und" => map.name}
      assert hd(entity[:attributed_to])[:inbox] == "https://alex.gitlab.com/inbox"
      assert hd(entity["attributed_to"])["inbox"] == "https://alex.gitlab.com/inbox"

      assert entity[:new_field] == map.new_field
      assert entity["new_field"] == map.new_field

      assert entity[:url] == [map.url]
    end

    test "activities" do
      map = %{
        "summary" => "John followed Sally",
        "id" => "http://example.org/activities/123",
        "type" => "Follow",
        "actor" => "https://john.example.org",
        "object" => "https://sally.example.org",
        "context" => "http://example.org/connections/123"
      }

      assert {:ok, entity} = Entity.parse(map)
      assert ["https://john.example.org"] == entity[:actor]
      assert ["https://sally.example.org"] == entity[:object]
      assert ["http://example.org/connections/123"] == entity[:context]
      assert entity[:summary] == %{"und" => map["summary"]}
      assert entity[:id] == map["id"]
    end

    test "actor" do
      map = %{
        "@context": ["https://www.w3.org/ns/activitystreams", %{"@language": "ja"}],
        type: "Person",
        id: "https://kenzoishii.example.com/",
        following: "https://kenzoishii.example.com/following.json",
        followers: "https://kenzoishii.example.com/followers.json",
        liked: "https://kenzoishii.example.com/liked.json",
        inbox: "https://kenzoishii.example.com/inbox.json",
        outbox: "https://kenzoishii.example.com/feed.json",
        preferredUsername: "kenzoishii",
        name: "石井健蔵",
        summary: "この方はただの例です",
        icon: [
          "https://kenzoishii.example.com/image/165987aklre4"
        ]
      }

      assert {:ok, entity} = Entity.parse(map)
      assert entity[:type] == ~w[Object Actor Person]
      assert entity[:id] == map[:id]
      assert entity[:following] == map[:following]
      assert entity[:liked] == map[:liked]
      assert entity[:inbox] == map[:inbox]
      assert entity[:outbox] == map[:outbox]
      assert entity[:preferred_username] == map[:preferredUsername]
      assert entity[:name] == %{"und" => map[:name]}
      assert entity[:summary] == %{"und" => map[:summary]}
      assert entity[:icon] == map[:icon]
    end

    test "collection page" do
      map = %{
        "@context": "https://www.w3.org/ns/activitystreams",
        summary: "Page 1 of Sally's notes",
        type: "CollectionPage",
        id: "http://example.org/collection?page=1",
        partOf: "http://example.org/collection",
        items: [
          %{
            type: "Note",
            name: "Pizza Toppings to Try"
          },
          %{
            type: "Note",
            name: "Thought about California"
          }
        ]
      }

      assert {:ok, entity} = Entity.parse(map)
      # FIXME
      # assert entity[:"@context"] == map[:"@context"]
      assert entity[:type] == ~w[Object Collection CollectionPage]
      assert entity[:id] == map[:id]
      assert entity[:summary] == %{"und" => map[:summary]}
      # FIXME
      assert entity[:part_of] == ["http://example.org/collection"]
      assert [item_1, item_2] = entity[:items]

      assert item_1[:type] == ~w(Object Note)
      assert item_1[:name] == %{"und" => "Pizza Toppings to Try"}

      assert item_2[:type] == ~w(Object Note)
      assert item_2[:name] == %{"und" => "Thought about California"}
    end

    test "link" do
      map = %{
        "@context": "https://www.w3.org/ns/activitystreams",
        type: "Link",
        href: "http://example.org/abc",
        hreflang: "en",
        mediaType: "text/html",
        name: "An example link"
      }

      assert {:ok, entity} = Entity.parse(map)
      # FIXME
      # assert entity[:"@context"] == map[:"@context"]
      assert entity[:type] == ~w[Link]
      assert entity[:href] == map[:href]
      assert entity[:hreflang] == map[:hreflang]
      assert entity[:media_type] == map[:mediaType]
      assert entity[:name] == map[:name]
    end
  end
end
