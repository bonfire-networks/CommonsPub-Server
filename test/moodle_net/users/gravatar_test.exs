# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.GravatarTest do
  use MoodleNet.DataCase, async: true

  alias MoodleNet.Users.Gravatar

  test "works" do
    assert "https://s.gravatar.com/avatar/7779b850ea05dbeca7fc39a910a77f21?d=identicon&r=g&s=80" == Gravatar.url("alex@moodle.com")
  end
end
