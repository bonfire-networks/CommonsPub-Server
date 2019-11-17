# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Instance.Outbox do
  use MoodleNet.Common.Schema
  alias Mootils.Cursor
  alias MoodleNet.Activities.Activity

  cursor_schema "mn_instance_outbox" do
    belongs_to(:activity, Activity)
  end

  def create_changeset(%Activity{id: id}) do
    changes = [ id: Cursor.generate_bose64(), activity_id: id ]
    Changeset.change(%__MODULE__{}, changes)
  end

end
