defmodule ActivityPub.SQLEntityTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.Entito, as: Entity
  alias ActivityPub.SQLEntity

  describe "persist" do
    test "works" do
      map = %{
        type: "Object",
        content: "This is a content",
        name: "This is my name",
        end_time: "2015-01-01T06:00:00-08:00",
        new_field: "extra",
        url: "https://alex.gitlab.com/profile"
      }

      assert {:ok, entity} = Entity.parse(map)
      assert {:ok, result} = SQLEntity.persist(entity)
      IO.inspect(result)
    end
  end
end
