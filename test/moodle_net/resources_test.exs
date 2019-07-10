# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.ResourcesTest do
  use MoodleNet.DataCase, async: true

  import ActivityPub.Entity, only: [local_id: 1]
  alias MoodleNet.Resources

  describe "resource flags" do
    test "works" do
      actor = Factory.actor()
      actor_id = local_id(actor)
      comm = Factory.community(actor)
      coll = Factory.collection(actor, comm)
      res = Factory.resource(actor, coll)
      res_id = local_id(res)

      assert [] = Resources.all_flags(actor)

      {:ok, _activity} = Resources.flag(actor, res, %{reason: "Terrible joke"})

      assert [flag] = Resources.all_flags(actor)
      assert flag.flagged_object_id == res_id
      assert flag.flagging_object_id == actor_id
      assert flag.reason == "Terrible joke"
      assert flag.open == true
    end
  end

end
