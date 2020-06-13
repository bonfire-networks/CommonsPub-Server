# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
defmodule MoodleNet.Repo.Migrations.NewPointersLib do
  use Ecto.Migration

  def up(), do: inits(:up)
  def down(), do: inits(:down)

  import Pointers.Migration
  import Pointers.ULID.Migration
  
  defp inits(dir) do

    # init_pointers_ulid_extra(dir) # not needed if we already have pointers/ulid

    upgrade_table_key(:up) # needed if we already have pointers

    init_pointers(dir) # this one is not optional 
  end

end
