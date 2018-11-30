defmodule ActivityPub.SQLEntityTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.Entity
  alias ActivityPub.SQLEntity

  describe "persist" do
    test "works" do
      map = %{
        id: "https://alex.gitlab.com/",
        type: "Object",
        content: "This is a content",
        name: "This is my name",
        end_time: "2015-01-01T06:00:00-08:00",
        new_field: "extra",
        url: "https://alex.gitlab.com/profile"
      }

      assert {:ok, entity} = Entity.parse(map)
      assert {:ok, persisted} = SQLEntity.persist(entity)
      assert Map.delete(entity, :__ap__) == Map.delete(persisted, :__ap__)
    end

    test "adds id" do
      map = %{type: "Object"}
      assert {:ok, entity} = Entity.parse(map)
      refute entity.id
      assert {:ok, persisted} = SQLEntity.persist(entity)
      assert persisted.id
    end
  end
end
