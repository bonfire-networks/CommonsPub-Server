# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Test.FeedsTest do
  use MoodleNet.DataCase, async: true
  alias MoodleNet.{Feeds, Repo}

  describe "Creating and finding a feed" do
    test "works" do
      assert {:ok, feed} = Feeds.create_feed()
      assert {:ok, feed2} = Feeds.fetch_feed(feed.id)
    end
  end

  describe "Publishing to a feed" do
    test "works" do
      assert {:ok, feed} = Feeds.create_feed()
    end
  end

end
