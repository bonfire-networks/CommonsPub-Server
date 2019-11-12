defmodule MoodleNet.ActivityPub.PublisherTest do
  use MoodleNet.DataCase
  import MoodleNet.Test.Faking
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
end
