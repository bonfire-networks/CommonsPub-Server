# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Communities.Inbox do
  use MoodleNet.Common.Schema

  alias MoodleNet.Activities.Activity
  alias MoodleNet.Communities.Community
  alias Ecto.Changeset

  table_schema "mn_community_inbox" do
    belongs_to(:community, Community)
    belongs_to(:activity, Activity)
  end

  def changeset(%Community{} = c, %Activity{} = a) do
    changes = [
      community_id: c.id,
      activity_id: a.id,
    ]
    Changeset.change(%__MODULE__{}, changes)
  end

end
