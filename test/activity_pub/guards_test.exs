# defmodule ActivityPub.GuardsTest do
#   use MoodleNet.DataCase, async: true

#   alias ActivityPub.Entity

#   defmodule Foo do
#     require ActivityPub.Guards

#     def activity?(e) when is_activity(e), do: true
#     def activity?(e), do: false

#     def follow?(e) when is_follow(e), do: true
#     def follow?(e), do: false

#     def actor?(e) when is_actor(e), do: true
#     def actor?(e), do: false
#   end

#   @tag :skip
#   test "works" do
#     assert {:ok, follow} = Entity.parse(%{type: "Follow"})
#     assert {:ok, add} = Entity.parse(%{type: "Add"})
#     assert {:ok, person} = Entity.parse(%{type: "Person"})

#     assert Foo.follow?(follow)
#     refute Foo.follow?(add)
#     refute Foo.follow?(person)

#     assert Foo.activity?(follow)
#     assert Foo.activity?(add)
#     refute Foo.activity?(person)

#     refute Foo.actor?(follow)
#     refute Foo.actor?(add)
#     assert Foo.actor?(person)
#   end
# end
