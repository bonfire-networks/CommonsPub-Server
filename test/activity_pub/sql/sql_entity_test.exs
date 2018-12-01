defmodule ActivityPub.SQLEntityTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.Entity
  alias ActivityPub.SQLEntity

  describe "insert" do
    test "works with new entities" do
      map = %{
        type: "Object",
        content: "This is a content",
        name: "This is my name",
        end_time: "2015-01-01T06:00:00-08:00",
        extension_field: "extra"
      }

      assert {:ok, entity} = ActivityPub.new(map)
      assert {:ok, persisted} = SQLEntity.insert(entity)
      refute entity.id
      assert persisted.id
      assert Map.drop(entity, [:__ap__, :id]) == Map.drop(persisted, [:__ap__, :id])
    end

    test "works with new assocs" do
      map = %{
        type: "Create",
        summary: "Alex inserted a note",
        actor: %{
          type: "Person",
          name: "Alex",
          preferred_username: "alexcastano",
        },
        object: %{
          type: "Note",
          content: "This is a content",
          end_time: "2015-01-01T06:00:00-08:00",
          extension_field: "extra"
        }
      }

      # map = %{
      #   attributed_to: %{
      #     name: "alex"
      #   },
      #   content: "content"
      # }
      assert {:ok, entity} = ActivityPub.new(map)
      assert {:ok, persisted} = SQLEntity.insert(entity)
      assert persisted.type == ["Object", "Activity", "Create"]
      assert persisted.summary == %{"und" => map.summary}

      assert [actor] = persisted.actor
      assert actor.name == %{"und" => map.actor.name}
      assert actor.preferred_username == map.actor.preferred_username

      assert [object] = persisted.object
      assert object.content == %{"und" => map.object.content}
      assert %DateTime{} = object.end_time
      assert object["extension_field"] == map.object.extension_field
    end

    test "fails with not loaded assocs" do
      map = %{
        attributed_to: "https://moodle.net/user/alexcastano",
        content: "content"
      }

      assert {:ok, entity} = ActivityPub.new(map)
      assert {:error, _, %Ecto.Changeset{} = ch, _} = SQLEntity.insert(entity)
      IO.inspect(ch)
    end
  end
end
