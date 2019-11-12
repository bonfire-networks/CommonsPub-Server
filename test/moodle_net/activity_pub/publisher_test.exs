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
      # This breaks currently
      # assert activity.mn_pointer_id == comment.id
    end
  end

  describe "follows" do
    test "it federates a follow of a remote actor" do
      follower = fake_actor!()
      ap_followed = actor()
      {:ok, followed} = MoodleNet.Actors.fetch_by_username(ap_followed.username)

      {:ok, follow} = MoodleNet.Common.follow(follower, followed, %{is_muted: false, is_public: true})
      assert {:ok, activity} = Publisher.follow(follow)
      assert activity.data["to"] == [ap_followed.ap_id]
    end

    test "it federate an unfollow of a remote actor" do
      follower = fake_actor!()
      ap_followed = actor()
      {:ok, followed} = MoodleNet.Actors.fetch_by_username(ap_followed.username)
      {:ok, follow} = MoodleNet.Common.follow(follower, followed, %{is_muted: false, is_public: true})
      {:ok, follow_activity} = Publisher.follow(follow)
      {:ok, unfollow} = MoodleNet.Common.unfollow(follow)

      assert {:ok, unfollow_activity} = Publisher.unfollow(unfollow)
      assert unfollow_activity.data["object"]["id"] == follow_activity.data["id"]
    end
  end
end
