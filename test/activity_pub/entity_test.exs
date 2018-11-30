defmodule ActivityPub.EntityTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.Entity

  describe "parse" do
    test "returns errors" do
      map = %{content: true}
      assert {:error, error} = Entity.parse(map)
      assert %{key: "content", message: "is invalid", value: true} = error
    end

    test "returns inner errors" do
      map = %{
        content: "good content",
        attributed_to: %{
          context: %{
            name: 1
          }
        }
      }

      assert {:error, error} = Entity.parse(map)
      assert %{key: "attributed_to.0.context.0.name", message: "is invalid", value: 1} = error
    end

    # test "simple objects" do
    #   map = %{
    #     attributed_to: [
    #       %{
    #         id: "https://alex.gitlab.com",
    #         type: "Person",
    #         name: "Alex",
    #         inbox: "https://alex.gitlab.com/inbox",
    #         outbox: "https://alex.gitlab.com/outbox"
    #       },
    #       "https://doug.gitlab.com"
    #     ],
    #     type: "Object",
    #     content: "This is a content",
    #     name: "This is my name",
    #     end_time: "2015-01-01T06:00:00-08:00",
    #     new_field: "extra",
    #     url: "https://alex.gitlab.com/profile"
    #   }

    #   assert {:ok, entity} = Entity.parse(map)
    #   assert entity.content == %{"und" => map.content}
    #   assert entity.name == %{"und" => map.name}
    #   assert %DateTime{
    #     year: 2015,
    #     month: 1,
    #     day: 1,
    #     hour: 14,
    #     minute: 0,
    #     second: 0
    #   } = entity.end_time

    #   assert entity["new_field"] == map.new_field
    #   assert entity[:url] == [map.url]

    #   assert hd(entity.attributed_to)["inbox"] == "https://alex.gitlab.com/inbox"
    # end
  end
end
