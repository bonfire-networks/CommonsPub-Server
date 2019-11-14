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
      assert activity.local == true
      assert activity.object.local == true
    end

    # This should work but context function for creating replies is missing and changeset
    # function returns an error.
    @tag :skip
    test "it federates a reply to a comment" do
      actor = fake_actor!()
      commented_actor = fake_actor!()
      thread = fake_thread!(actor, commented_actor)
      comment = fake_comment!(actor, thread)
      # Publish the comment first so we can reply to it
      Publisher.comment(comment)
      reply = fake_comment!(commented_actor, thread)
      changeset = MoodleNet.Comments.Comment.reply_to_changeset(reply, comment)
      {:ok, reply} = MoodleNet.Repo.update(changeset)

      IO.inspect(reply)
      assert {:ok, activity} = Publisher.comment(reply)
      assert activity.object.data["inReplyTo"]
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

  describe "likes" do
    test "it likes a comment" do
      actor = fake_actor!()
      commented_actor = fake_actor!()
      thread = fake_thread!(actor, commented_actor)
      comment = fake_comment!(actor, thread)
      # Comment needs to be published before it can be liked
      Publisher.comment(comment)

      {:ok, like} = MoodleNet.Common.like(commented_actor, comment, %{is_public: true})
      assert {:ok, like_activity, object} = Publisher.like(like)
      assert like_activity.data["object"] == object.data["id"]
    end

    test "it unlikes a comment" do
      actor = fake_actor!()
      commented_actor = fake_actor!()
      thread = fake_thread!(actor, commented_actor)
      comment = fake_comment!(actor, thread)
      # Comment needs to be published before it can be liked
      Publisher.comment(comment)
      {:ok, like} = MoodleNet.Common.like(commented_actor, comment, %{is_public: true})
      Publisher.like(like)
      # No context function for unliking
      assert {:ok, unlike_activity, like_activity, object} = Publisher.unlike(like)
      assert like_activity.data["object"] == object.data["id"]
      assert unlike_activity.data["object"] == like_activity.data
    end
  end
end
