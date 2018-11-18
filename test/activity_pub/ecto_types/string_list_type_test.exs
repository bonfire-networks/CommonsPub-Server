defmodule ActivityPub.StringListTypeTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.StringListType, as: Subject
  describe "cast" do
    test "works" do
      assert {:ok, []} == Subject.cast(nil)
      assert {:ok, []} == Subject.cast([])
      assert {:ok, ["linux"]} == Subject.cast("linux")
      assert {:ok, [""]} == Subject.cast([""])
      assert {:ok, ["linux", "bsd"]} == Subject.cast(["linux", "bsd"])

      assert :error == Subject.cast(true)
      assert :error == Subject.cast([true])
    end
  end
end
