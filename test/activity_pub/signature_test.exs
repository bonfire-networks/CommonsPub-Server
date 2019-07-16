# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.SignatureTest do
  use MoodleNet.DataCase

  import MoodleNet.Factory

  alias ActivityPub.Signature

  describe "sign/2" do
    test "works" do
      actor = actor()

      signature =
        Signature.sign(actor, %{
          host: "test.test",
          "content-length": 100
        })
    end
  end
end
