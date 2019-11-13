defmodule MoodleNet.ActivityPub.PublisherTest do
  use MoodleNet.DataCase
  import MoodleNet.Test.Faking
  import ActivityPub.Factory
  alias MoodleNet.ActivityPub.Publisher

  describe "comments" do
    test "it federates a comment that's threaded on an actor" do
      actor = fake_actor!()
      commented_actor = fake_actor!()
      thread = fake_thread!(actor, commented_actor)
      comment = fake_comment!(actor, thread)

      assert {:ok, activity} = Publisher.comment(comment)
      assert activity.object.mn_pointer_id == comment.id
    end
  end

  describe "follows" do
    test "it federates a follow of a remote actor" do
      follower = fake_actor!()
      ap_followed = actor()
      {:ok, followed} = MoodleNet.Actors.fetch_by_username(ap_followed.username)

      {:ok, follow} =
        MoodleNet.Common.follow(follower, followed, %{is_muted: false, is_public: true})

      assert {:ok, activity} = Publisher.follow(follow)
      assert activity.data["to"] == [ap_followed.ap_id]
    end

    test "it federate an unfollow of a remote actor" do
      follower = fake_actor!()
      ap_followed = actor()
      {:ok, followed} = MoodleNet.Actors.fetch_by_username(ap_followed.username)

      {:ok, follow} =
        MoodleNet.Common.follow(follower, followed, %{is_muted: false, is_public: true})

      {:ok, follow_activity} = Publisher.follow(follow)
      {:ok, unfollow} = MoodleNet.Common.unfollow(follow)

      assert {:ok, unfollow_activity} = Publisher.unfollow(unfollow)
      assert unfollow_activity.data["object"]["id"] == follow_activity.data["id"]
    end

    test "it errors when remote account manually approves followers" do
      follower = fake_actor!()
      ap_followed = actor(%{data: %{"manuallyApprovesFollowers" => true}})
      {:ok, followed} = MoodleNet.Actors.fetch_by_username(ap_followed.username)

      {:ok, follow} =
        MoodleNet.Common.follow(follower, followed, %{is_muted: false, is_public: true})

      assert {:error, "account is private"} = Publisher.follow(follow)
    end
  end

  describe "blocks" do
    test "it federates a block of a remote actor" do
      blocker = fake_actor!()
      ap_blocked = actor()
      {:ok, blocked} = MoodleNet.Actors.fetch_by_username(ap_blocked.username)

      {:ok, block} =
        MoodleNet.Common.block(blocker, blocked, %{
          is_muted: false,
          is_public: true,
          is_blocked: false
        })

      assert {:ok, activity} = Publisher.block(block)
      assert activity.data["to"] == [ap_blocked.ap_id]
    end

    test "it federate an unblock of a remote actor" do
      blocker = fake_actor!()
      ap_blocked = actor()
      {:ok, blocked} = MoodleNet.Actors.fetch_by_username(ap_blocked.username)

      {:ok, block} =
        MoodleNet.Common.block(blocker, blocked, %{
          is_muted: false,
          is_public: true,
          is_blocked: false
        })

      {:ok, block_activity} = Publisher.block(block)
      {:ok, unblock} = MoodleNet.Common.delete_block(block)

      assert {:ok, unblock_activity} = Publisher.unblock(unblock)
      assert unblock_activity.data["object"]["id"] == block_activity.data["id"]
    end
  end

  describe "flags" do
    test "it flags an actor" do
      flagger = fake_actor!()
      ap_flagged = actor()
      {:ok, flagged} = MoodleNet.Actors.fetch_by_username(ap_flagged.username)
      {:ok, flag} = MoodleNet.Common.flag(flagger, flagged, %{message: "blocked AND reported!!!"})
      assert {:ok, activity} = Publisher.flag(flag)
    end

    test "if flags a comment" do
      actor = fake_actor!()
      commented_actor = fake_actor!()
      thread = fake_thread!(actor, commented_actor)
      comment = fake_comment!(actor, thread)
      # Comment needs to be published before the flag can be federated
      Publisher.comment(comment)

      {:ok, flag} =
        MoodleNet.Common.flag(commented_actor, comment, %{message: "blocked AND reported!!!"})

      assert {:ok, activity} = Publisher.flag(flag)
    end
  end
end
