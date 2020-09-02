defmodule CommonsPub.Repo.Migrations.NewPointersLib do
  use Ecto.Migration
  import Pointers.Migration
  import Pointers.ULID.Migration

  # NOTE: we're cheating here and backdating this migration to use new Pointers lib

  def up() do
    # needed only if we already have pointers
    # pointers_upgrade_table_key(:up)

    # add pointers from lib
    inits(:up)
  end

  def down(), do: inits(:down)

  defp inits(dir) do
    # not needed if we already have pointers/ulid
    init_pointers_ulid_extra(dir)

    # this one is not optional
    init_pointers(dir)
  end

  def pointers_upgrade_table_key(:up) do
    pt = Application.get_env(:pointers, :schema_pointers, "pointers_pointer")
    ptt = Application.get_env(:pointers, :schema_pointers, "pointers_table")

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
