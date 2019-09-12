# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Test.Faking do
  alias MoodleNet.Test.Fake
  alias MoodleNet.Meta
  alias MoodleNet.Peers
  alias MoodleNet.Repo
  
  def fake_peer!(overrides \\ %{}) when is_map(overrides),
    do: Peers.create!(Fake.peer(overrides))
  
end
