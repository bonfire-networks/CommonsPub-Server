# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Collections.Inbox do
  use MoodleNet.Common.Schema
  alias Mootils.Cursor
  alias MoodleNet.Activities.Activity
  alias MoodleNet.Collections.Collection

  cursor_schema "mn_collection_inbox" do
    belongs_to(:collection, Collection)
    belongs_to(:activity, Activity)
  end

  def create_changeset(%Collection{} = c, %Activity{} = a) do
    changes = [
      id: Cursor.generate_bose64(),
      collection_id: c.id,
      activity_id: a.id,
    ]
    Changeset.change(%__MODULE__{}, changes)
  end

end
