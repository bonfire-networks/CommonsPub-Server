defmodule ActivityPub.TypesTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.{
    ObjectAspect,
    ActorAspect,
    LinkAspect,
    CollectionAspect,
  }

  alias ActivityPub.Types

  test "parse/1 works" do
    assert Types.parse(nil) == {:ok, ["Object"]}
    assert Types.parse("Object") == {:ok, ["Object"]}
    assert Types.parse(["Object"]) == {:ok, ["Object"]}
    assert Types.parse(["Person"]) == {:ok, ["Object", "Actor", "Person"]}

    assert Types.parse("Unknown") == {:ok, ["Object", "Unknown"]}
    assert Types.parse(true) == :error
  end

  test "aspects/1 works" do
    assert Types.aspects("Object") == [ObjectAspect]
    assert Types.aspects(["Link"]) == [LinkAspect]

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
