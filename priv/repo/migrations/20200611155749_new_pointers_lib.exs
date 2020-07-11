# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
defmodule MoodleNet.Repo.Migrations.NewPointersLib do
  use Ecto.Migration

  def up() do
    # needed if we already have pointers
    pointers_upgrade_table_key(:up)
    inits(:up)
  end

  def down(), do: inits(:down)

  import Pointers.Migration
  import Pointers.ULID.Migration

  defp inits(dir) do
    # init_pointers_ulid_extra(dir) # not needed if we already have pointers/ulid

    # init_pointers(dir) # this one is not optional (unless in this case, where we alreay have mn_table and mn_pointer?)
  end

  def pointers_upgrade_table_key(:up) do
    pt = Application.get_env(:pointers, :schema_pointers, "mn_pointer")
    ptt = Application.get_env(:pointers, :schema_pointers, "mn_table")

    drop(constraint(pt, "mn_pointer_table_id_fkey"))

    alter table(pt) do
      modify(
        :table_id,
        references(ptt, on_delete: :delete_all, on_update: :update_all, type: :uuid),
        null: false
      )
    end
  end
end
