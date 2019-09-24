# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Peers.PeerTest do
  use MoodleNet.DataCase, async: true

  alias MoodleNet.Repo
  alias MoodleNet.Meta
  alias MoodleNet.Peers.Peer

  test "succeeds if provided a valid URL" do
    invalid_urls = [
      "http://elixir-lang.org",
      "https://elixir-lang.org/",
      "https://elixir-lang.org/foo/bar"
    ]

    Repo.transaction(fn ->
      pointer = Meta.point_to!(Peer)
      for url <- invalid_urls do
        changeset = Peer.create_changeset(pointer, %{"ap_url_base" => url})
        refute Keyword.get(changeset.errors, :ap_url_base)
      end
    end)
  end

  test "fails if provided an invalid URL" do
    invalid_urls = [
      "//elixir-lang.org/",
      "ftp://elixir-lang.org",
      "http:///test"
    ]

    Repo.transaction(fn ->
      pointer = Meta.point_to!(Peer)
      for url <- invalid_urls do
        changeset = Peer.create_changeset(pointer, %{"ap_url_base" => url})
        assert Keyword.get(changeset.errors, :ap_url_base)
      end
    end)
  end
end
