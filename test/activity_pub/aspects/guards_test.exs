defmodule ActivityPub.GuardsTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.Entity

  defmodule Foo do
    import ActivityPub.Guards

    def activity?(%Entity{} = e) when is_activity(e), do: true
    def activity?(%Entity{} = e), do: false

    def follow?(%Entity{} = e) when is_follow(e), do: true
    def follow?(%Entity{} = e), do: false

    def actor?(%Entity{} = e) when is_actor(e), do: true
    def actor?(%Entity{} = e), do: false
  end

  test "works" do
    assert {:ok, follow} = Entity.parse(%{type: "Follow"})
    assert {:ok, add} = Entity.parse(%{type: "Add"})
    assert {:ok, person} = Entity.parse(%{type: "Person"})

    assert Foo.follow?(follow)
    refute Foo.follow?(add)
    refute Foo.follow?(person)

    assert Foo.activity?(follow)
    assert Foo.activity?(add)
    refute Foo.activity?(person)

    refute Foo.actor?(follow)
    refute Foo.actor?(add)
    assert Foo.actor?(person)
  end
end
