defmodule ActivityPub.SQLEntityTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.Entity
  alias ActivityPub.SQLEntity

  describe "create" do
    test "works with new entities" do
      map = %{
        type: "Object",
        content: "This is a content",
        name: "This is my name",
        end_time: "2015-01-01T06:00:00-08:00",
        new_field: "extra"
      }

      assert {:ok, entity} = ActivityPub.new(map)
      assert {:ok, persisted} = SQLEntity.create(entity)
      refute entity.id
      assert persisted.id
      assert Map.drop(entity, [:__ap__, :id]) == Map.drop(persisted, [:__ap__, :id])
    end
  end
end
