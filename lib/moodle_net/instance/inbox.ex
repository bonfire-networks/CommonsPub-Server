# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Instance.Inbox do
  use MoodleNet.Common.Schema
  alias MoodleNet.Activities.Activity
  alias Ecto.Changeset

  table_schema "mn_instance_inbox" do
    belongs_to(:activity, Activity)
  end

  def changeset(%Activity{id: id}) do
    Changeset.change(%__MODULE__{}, activity_id: id)
  end

end
