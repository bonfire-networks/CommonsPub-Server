# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
defmodule MoodleNet.Repo.Migrations.MigrateOrgToCircle do
  use Ecto.Migration

  def up do
    MoodleNet.ReleaseTasks.remove_meta_table("mn_circle")
    MoodleNet.ReleaseTasks.remove_meta_table("circle")


    Circle.Migrations.down()
    Circle.Migrations.change_simpler(:up)
    Circle.Migrations.up_pointer()

  end

  def down do

    Circle.Migrations.change_simpler(:down)
    MoodleNet.ReleaseTasks.remove_meta_table("circle")

  end

end
