# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.CommentsTest do
  use MoodleNet.DataCase, async: true

  import ActivityPub.Entity, only: [local_id: 1]
  alias MoodleNet.Comments
  alias MoodleNet.Meta
  alias MoodleNet.Test.{Fake, Faking}

  describe "create_thread" do
    test "creates a new thread with any parent" do
      resource = Faking.fake_resource!()
      attrs = Fake.thread()
      assert {:ok, thread} = Comments.create_thread(Meta.find!(resource.id), attrs)
      assert thread.is_public == attrs.is_public
    end
  end

  describe "comment flags" do
    test "works" do
      actor = Factory.actor()
      actor_id = local_id(actor)
      comm = Factory.community(actor)
      comment = Factory.comment(actor, comm)
      comment_id = local_id(comment)

      assert [] = Comments.all_flags(actor)

      {:ok, _activity} = Comments.flag(actor, comment, %{reason: "Terrible joke"})

      assert [flag] = Comments.all_flags(actor)
      assert flag.flagged_object_id == comment_id
      assert flag.flagging_object_id == actor_id
      assert flag.reason == "Terrible joke"
      assert flag.open == true
    end
  end

end
