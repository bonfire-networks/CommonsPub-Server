# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.StringListTypeTest do
  use MoodleNet.DataCase, async: true

  alias ActivityPub.StringListType, as: Subject
  describe "cast" do
    test "works" do
      assert {:ok, []} == Subject.cast(nil)
      assert {:ok, []} == Subject.cast([])
      assert {:ok, ["linux"]} == Subject.cast("linux")
      assert {:ok, [""]} == Subject.cast([""])
      assert {:ok, ["linux", "bsd"]} == Subject.cast(["linux", "bsd"])

      assert :error == Subject.cast(true)
      assert :error == Subject.cast([true])
    end
  end
end
