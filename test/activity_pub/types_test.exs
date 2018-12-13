defmodule ActivityPub.TypesTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.{
    ObjectAspect,
    ActorAspect,
    # LinkAspect,
    CollectionAspect,
  }

  alias ActivityPub.Types
  alias ActivityPub.BuildError

  test "build/1 works" do
    assert Types.build(nil) == {:ok, ["Object"]}
    assert Types.build("Object") == {:ok, ["Object"]}
    assert Types.build(["Object"]) == {:ok, ["Object"]}
    assert Types.build(["Person"]) == {:ok, ["Object", "Actor", "Person"]}

    assert Types.build("Unknown") == {:ok, ["Object", "Unknown"]}
    assert %BuildError{path: ["type"], value: true, message: "is invalid"} = Types.build(true)
  end

  test "aspects/1 works" do
    assert Types.aspects("Object") == [ObjectAspect]
    # FIXME
    # assert Types.aspects(["Link"]) == [LinkAspect]

    assert Types.aspects(["Object", "Actor", "Group", "Collection"]) == [
             ObjectAspect,
             ActorAspect,
             CollectionAspect
           ]
  end

  test "ancestors/1 works" do
    assert Types.ancestors("Join") == ~w(Object Activity Join)
    assert Types.ancestors("Link") == ~w(Link)
    assert Types.ancestors(["Group", "Collection"]) == ~w(Object Actor Group Collection)
  end

  test "all/1 works" do
    assert list = Types.all()
    assert is_list(list)
    assert length(list) > 20
  end
end
