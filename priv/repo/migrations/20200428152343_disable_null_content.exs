# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
defmodule MoodleNet.Repo.Migrations.DisableNullContent do
  use Ecto.Migration

  def up do
    # clean up - may cause data loss
    :ok = execute("delete from mn_resource where content_id is null")
    :ok = execute("alter table mn_resource alter column content_id set not null")
  end

  def down do
    # :ok = execute "alter table mn_resource alter column content_id set null;"
  end
end
