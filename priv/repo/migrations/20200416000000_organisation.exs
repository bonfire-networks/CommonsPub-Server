# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
defmodule MoodleNet.Repo.Migrations.Circle do
    use Ecto.Migration

    def up do
      Circle.Migrations.up()
    end

    def down do
      Circle.Migrations.down()
    end
end
