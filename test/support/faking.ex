# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Test.Faking do
  alias MoodleNet.Test.Fake
  alias MoodleNet.{Meta,Peers,Repo}
  alias MoodleNet.Peers.Peer
  
  def fake_peer!(overrides \\ %{}) when is_map(overrides) do
    pointer = Meta.point_to!(Peer)
    {:ok, peer} = Peers.create(pointer, Fake.peer(overrides))
    peer
  end
  
end
