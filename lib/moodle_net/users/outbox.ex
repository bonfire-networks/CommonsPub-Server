# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.Outbox do
  use MoodleNet.Common.Schema

  meta_schema "mn_user_outbox" do
    belongs_to(:user, User)
    belongs_to(:activity, Activity)
    timestamps(inserted_at: :created_at)
  end
end
