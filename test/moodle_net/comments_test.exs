# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.CommentsTest do
  use MoodleNet.DataCase, async: true

  import ActivityPub.Entity, only: [local_id: 1]
  alias MoodleNet.Comments
  alias ActivityPub.SQL.Query

  describe "comment flags" do
    test "works" do
      actor = Factory.actor()
      actor_id = local_id(actor)
      comm = Factory.community(actor)
      comment = Factory.comment(actor, comm)
      comment_id = local_id(comment)

      assert [] = Comments.flags(actor)

      {:ok, activity} = Comments.flag(actor, comment, %{reason: "Terrible joke"})

      assert [flag] = Comments.flags(actor)
      assert flag.flagged_object_id == comment_id
      assert flag.flagging_object_id == actor_id
      assert flag.reason == "Terrible joke"
      assert flag.open == true
    end
  end

end
