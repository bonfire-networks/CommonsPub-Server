# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Comments.ThreadFollowerCount do
  use MoodleNet.Common.Schema
  alias MoodleNet.Comments.Thread

  view_schema "mn_thread_follower_count" do
    belongs_to(:thread, Thread, primary_key: true)
    field(:count, :integer)
  end
end
