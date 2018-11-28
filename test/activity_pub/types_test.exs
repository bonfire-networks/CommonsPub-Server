defmodule ActivityPub.TypesTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.Types
  describe "parse" do
    test "works" do
      assert Types.parse(nil) == {:ok, ["Object"]}
      assert Types.parse("Object") == {:ok, ["Object"]}
      assert Types.parse(["Object"]) == {:ok, ["Object"]}
      assert Types.parse(["Person"]) == {:ok, ["Object", "Actor", "Person"]}


      assert Types.parse("Unknown") == {:ok, ["Object", "Unknown"]}
      assert Types.parse(true) == :error
    end
  end
end
