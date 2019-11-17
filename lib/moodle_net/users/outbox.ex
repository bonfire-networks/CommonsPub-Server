# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.Outbox do
  use MoodleNet.Common.Schema
  alias Mootils.Cursor
  alias MoodleNet.Activities.Activity
  alias MoodleNet.Users.User

  cursor_schema "mn_user_outbox" do
    belongs_to(:user, User)
    belongs_to(:activity, Activity)
  end

  def create_changeset(%User{} = u, %Activity{} = a) do
    changes = [
      id: Cursor.generate_bose64(),
      user_id: u.id,
      activity_id: a.id,
    ]
    Changeset.change(%__MODULE__{}, changes)
  end

end
