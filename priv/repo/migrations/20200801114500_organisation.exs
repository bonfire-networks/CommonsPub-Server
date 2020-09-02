defmodule CommonsPub.Repo.Migrations.ReaddOrganisation do
  use Ecto.Migration

  def up do
    # Pointers.Migration.create_main_pointer_trigger_function()
    # flush()
    # Organisation.Migrations.down_circle()
    Pointers.Migration.create_pointer_trigger_function()
    flush()
    Organisation.Migrations.up()
  end

  def down do
    Organisation.Migrations.down()
  end
end
