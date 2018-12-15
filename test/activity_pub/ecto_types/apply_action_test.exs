defmodule ActivityPub.ApplyActionTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.SQL.{Query}

  import ActivityPub, only: [apply: 1]

  describe "follow" do
    test "works" do
      follower_actor = Factory.actor()
      following_actor = Factory.actor()

      follow = %{
        type: "Follow",
        actor: follower_actor,
        object: following_actor,
      }
      assert {:ok, follow} = ActivityPub.new(follow)
      assert {:ok, follow} = apply(follow)

      refute Query.has?(follower_actor, :followers, following_actor)
      refute Query.has?(following_actor, :following, follower_actor)
      assert Query.has?(following_actor, :followers, follower_actor)
      assert Query.has?(follower_actor, :following, following_actor)
    end
  end

  describe "like" do
    test "works" do
      liker_actor = Factory.actor()
      liked_actor = Factory.actor()

      like = %{
        type: "Like",
        actor: liker_actor,
        object: liked_actor,
      }
      assert {:ok, like} = ActivityPub.new(like)
      assert {:ok, like} = apply(like)

      refute Query.has?(liker_actor, :likers, liked_actor)
      refute Query.has?(liked_actor, :liked, liker_actor)
      assert Query.has?(liker_actor, :liked, liked_actor)
      assert Query.has?(liked_actor, :likers, liker_actor)
    end
  end
end
