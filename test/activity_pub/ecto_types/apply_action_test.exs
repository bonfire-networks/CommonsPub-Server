defmodule ActivityPub.ApplyActionTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.SQL.CollectionStatement

  import ActivityPub, only: [apply: 1]

  describe "follow" do
    test "works" do
      follower_actor = Factory.actor()
      following_actor = Factory.actor()

      create = %{
        type: "Follow",
        actor: follower_actor,
        object: following_actor,
      }
      assert {:ok, create} = ActivityPub.new(create)
      assert {:ok, create} = apply(create)

      refute CollectionStatement.in?(follower_actor.followers, following_actor)
      refute CollectionStatement.in?(following_actor.following, follower_actor)
      assert CollectionStatement.in?(following_actor.followers, follower_actor)
      assert CollectionStatement.in?(follower_actor.following, following_actor)
    end
  end
end
