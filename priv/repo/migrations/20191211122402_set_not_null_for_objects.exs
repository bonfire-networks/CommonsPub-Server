# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
defmodule MoodleNet.Repo.Migrations.SetNotNullForObjects do
  use Ecto.Migration

  # modify/3 function will require index recreation, so using execute/1 instead

  def up do
    execute("ALTER TABLE ap_object
    ALTER COLUMN data SET NOT NULL")
  end

  def down do
    execute("ALTER TABLE ap_object
    ALTER COLUMN data DROP NOT NULL")
  end
end
