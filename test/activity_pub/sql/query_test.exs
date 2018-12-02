defmodule ActivityPub.SQL.QueryTest do
  use MoodleNet.DataCase, async: true
  alias ActivityPub.SQL.Query

  def insert(map) do
    {:ok, e} = ActivityPub.new(map)
    {:ok, e} = ActivityPub.SQLEntity.insert(e)
    e
  end

  test "all/1 works" do
    assert [] = Query.new() |> Query.all()

    assert %{id: id} = insert(%{})

    assert [%{id: ^id}] = Query.new() |> Query.all()
  end

  test "one/1 works" do
    assert nil == Query.new() |> Query.one()
    assert %{id: id} = insert(%{})
    assert %{id: ^id} = Query.new() |> Query.one()
    insert(%{})

    assert_raise Ecto.MultipleResultsError, fn ->
      assert %{id: ^id} = Query.new() |> Query.one()
    end
  end

  test "with_type/2 works" do
    assert %{id: person_id} = insert(%{type: "Person"})
    assert [] = Query.new() |> Query.with_type("Activity") |> Query.all()

    assert %{id: activity_id} = insert(%{type: "Activity"})

    assert %{id: ^person_id} = Query.new() |> Query.with_type("Person") |> Query.one()
    assert %{id: ^person_id} = Query.new() |> Query.with_type("Actor") |> Query.one()

    assert MapSet.new([person_id, activity_id]) ==
             Query.new()
             |> Query.with_type("Object")
             |> Query.all()
             |> Enum.map(& &1.id)
             |> MapSet.new()
  end

  alias ActivityPub.SQL.{FieldNotLoaded}

  describe "preload_aspect/2" do
    test "works" do
      insert(%{type: "Person", preferred_username: "alexcastano"})

      assert loaded_actor = Query.new() |> Query.one()
      assert %FieldNotLoaded{} = loaded_actor.preferred_username

      assert loaded_actor = Query.new() |> Query.preload_aspect(:actor) |> Query.one()
      assert "alexcastano" = loaded_actor.preferred_username

      # object aspect is already loaded so it is allowed but do nothing
      assert loaded_actor_2 =
               Query.new() |> Query.preload_aspect([:object, :actor]) |> Query.one()

      assert loaded_actor_2 == loaded_actor
    end

    test "allows preload many times" do
      Query.new()
      |> Query.preload_aspect([:activity, :actor])
      |> Query.preload_aspect([:activity, :actor])
    end
  end

  test "has/3 and belongs_to/3 work" do
    child =
      %{id: child_id, attributed_to: [parent = %{id: parent_id}]} = insert(%{attributed_to: %{}})

    assert %{id: ^child_id} =
             Query.new()
             |> Query.has(:attributed_to, parent)
             |> Query.one()

    assert %{id: ^parent_id} =
             Query.new()
             |> Query.belongs_to(:attributed_to, child)
             |> Query.one()
  end
end
