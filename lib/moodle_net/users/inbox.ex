# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.Inbox do
  use MoodleNet.Common.Schema

  meta_schema "mn_user_inbox" do
    belongs_to(:user, User)
    belongs_to(:activity, Activity)
    timestamps(updated_at: false)
  end
end
