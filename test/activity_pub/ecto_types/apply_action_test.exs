defmodule ActivityPub.ApplyActionTest do
  use ActivityPub.DataCase, async: true

  alias ActivityPub.SQL.CollectionStatement

  import ActivityPub, only: [apply: 1]

  describe "follow" do
    test "works" do
      follower = Factory.actor()
      following = Factory.actor()

      create = %{
        type: "Follow",
        actor: follower,
        object: following,
      }

      assert {:ok, create} = apply(create)

      assert CollectionStatement.in?(create.actor.follower, create.object)
    end
  end
end
