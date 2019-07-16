# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.UsersTest do
  use MoodleNet.DataCase, async: true

  import ActivityPub.Entity, only: [local_id: 1]
  alias MoodleNet.Users

  describe "user flags" do
    test "works" do
      actor = Factory.actor()
      actor_id = local_id(actor)
      user = Factory.actor()
      user_id = local_id(user)

      assert [] = Users.all_flags(actor)

      {:ok, _activity} = Users.flag(actor, user, %{reason: "Terrible joke"})

      assert [flag] = Users.all_flags(actor)
      assert flag.flagged_object_id == user_id
      assert flag.flagging_object_id == actor_id
      assert flag.reason == "Terrible joke"
      assert flag.open == true
    end
  end

end
