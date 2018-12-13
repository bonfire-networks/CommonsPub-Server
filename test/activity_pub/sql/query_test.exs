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

  test "reload/1" do
    map = %{type: "Person", preferred_username: "alex"}
    assert person = insert(map)
    assert reloaded = Query.reload(person)
    assert reloaded.preferred_username == "alex"
  end

  test "with_type/2 works" do
    assert %{id: person_id} = insert(%{type: "Person"})
    assert [] = Query.new() |> Query.with_type("Activity") |> Query.all()

    assert %{id: activity_id} = insert(%{type: "Activity"})

    assert %{id: ^person_id} = Query.new() |> Query.with_type("Person") |> Query.one()
    assert %{id: ^person_id} = Query.new() |> Query.with_type("Actor") |> Query.one()
  end

  alias ActivityPub.SQL.{FieldNotLoaded, AssociationNotLoaded}

  describe "preload_aspect/2" do
    test "works" do
      insert(%{type: "Person", preferred_username: "alexcastano"})

      assert loaded_actor = Query.new() |> Query.with_type("Person") |> Query.one()
      assert %FieldNotLoaded{} = loaded_actor.preferred_username

      assert loaded_actor =
               Query.new()
               |> Query.with_type("Person")
               |> Query.preload_aspect(:actor)
               |> Query.one()

      assert "alexcastano" = loaded_actor.preferred_username

      # object aspect is already loaded so it is allowed but do nothing
      assert loaded_actor_2 =
               Query.new()
               |> Query.with_type("Person")
               |> Query.preload_aspect([:object, :actor])
               |> Query.one()

      assert loaded_actor_2 == loaded_actor
    end

    test "allows preload many times" do
      Query.new()
      |> Query.preload_aspect([:activity, :actor])
      |> Query.preload_aspect([:activity, :actor])
    end
  end

  describe "preload_assoc/2" do
    test "works with single entity" do
      activity =
        insert(%{type: "Create", object: %{content: "foo"}})
        |> ActivityPub.Entity.local_id()
        |> ActivityPub.get_by_local_id()

      assert %AssociationNotLoaded{} = activity.object
      activity = Query.preload_assoc(activity, :object)
      assert %{"und" => "foo"} = get_in(activity, [:object, Access.at(0), :content])
    end

    test "works with multiple entities" do
      insert(%{type: "Create", object: %{content: "foo"}})
      insert(%{type: "Create", object: %{content: "bar"}})

      [foo, bar] = Query.new() |> Query.with_type("Create") |> Query.all()
      assert %AssociationNotLoaded{} = foo.object
      assert %AssociationNotLoaded{} = bar.object

      [bar, foo] = Query.preload_assoc([bar, foo], :object)

      assert %{"und" => "foo"} = get_in(foo, [:object, Access.at(0), :content])
      assert %{"und" => "bar"} = get_in(bar, [:object, Access.at(0), :content])
    end

    test "works with deeper assocs" do
      actor = insert(%{type: "Person"})
      activity =
        insert(%{type: "Create", actor: actor})
        |> ActivityPub.Entity.local_id()
        |> ActivityPub.get_by_local_id()

      activity = Query.preload_assoc(activity, actor: :followers)
      assert followers = get_in(activity, [:actor, Access.at(0), :followers])
      import ActivityPub.Guards
      assert has_type(followers, "Collection")
      assert %ActivityPub.SQL.AssociationNotLoaded{} = get_in(activity, [:actor, Access.at(0), :following])
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
