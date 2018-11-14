defmodule ActivityPubTest do
  use MoodleNet.DataCase, async: true
  doctest ActivityPub

  describe "object" do
    test "it ensures uniqueness of the id" do
      # FIXME
      # object = Factory.insert(:note)
      # {:error, cs} = ActivityPub.create_object(%{id: object.data["id"]})
      # refute cs.valid?
    end
  end

  describe "follow" do
    test "validates that following exists" do
      follower = Factory.actor()

      assert {:error, :follow, ch, _} =
        Multi.new()
        |> ActivityPub.follow(follower.id, 9932423948234890)
        |> Repo.transaction()

      assert "does not exist" in errors_on(ch).following_id
    end

    test "validates that follower exists" do
      following = Factory.actor()

      assert {:error, :follow, ch, _} =
        Multi.new()
        |> ActivityPub.follow(9932423948234890, following.id)
        |> Repo.transaction()

      assert "does not exist" in errors_on(ch).follower_id
    end

    test "updates counters and ignore multiple follows" do
      follower = Factory.actor()
      following = Factory.actor()

      assert {:ok, follow} =
        Multi.new()
        |> ActivityPub.follow(follower, following)
        |> Repo.transaction()

      assert %{
        followers_count: 0,
        following_count: 1
      } = ActivityPub.get_actor!(follower.id)

      assert %{
        followers_count: 1,
        following_count: 0
      } = ActivityPub.get_actor!(following.id)

      assert {:ok, follow_2} =
        Multi.new()
        |> ActivityPub.follow(follower, following)
        |> Repo.transaction()

      assert follow == follow_2

      assert %{
        followers_count: 0,
        following_count: 1
      } = ActivityPub.get_actor!(follower.id)

      assert %{
        followers_count: 1,
        following_count: 0
      } = ActivityPub.get_actor!(following.id)
    end
  end

  describe "unfollow" do
    test "works" do
      follower = Factory.actor()
      following = Factory.actor()

      assert {:ok, _follow} =
        Multi.new()
        |> ActivityPub.follow(follower, following)
        |> Repo.transaction()

      assert {:ok, _unfollow} =
        Multi.new()
        |> ActivityPub.unfollow(follower, following)
        |> Repo.transaction()

      assert %{
        followers_count: 0,
        following_count: 0
      } = ActivityPub.get_actor!(follower.id)

      assert %{
        followers_count: 0,
        following_count: 0
      } = ActivityPub.get_actor!(following.id)
    end
  end
end
