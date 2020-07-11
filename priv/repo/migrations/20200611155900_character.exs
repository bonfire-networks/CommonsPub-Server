# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
defmodule MoodleNet.Repo.Migrations.Character do
  use Ecto.Migration
  import Pointers.Migration

  def change(index_opts \\ []),
    do: Character.Migrations.migrate(index_opts, direction())
end
