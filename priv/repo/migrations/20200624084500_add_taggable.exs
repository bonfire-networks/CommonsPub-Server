defmodule CommonsPub.Repo.Migrations.AddTag do
  use Ecto.Migration

  def up do
    # Pointers.Migration.create_main_pointer_trigger_function()
    # flush()
    # Bonfire.TaxonomySeeder.Migrations.up()
    # flush()
    Bonfire.Tag.Migrations.up()
    Bonfire.Classify.Migrations.up()
  end

  def down do
    Bonfire.Tag.Migrations.down()
    Bonfire.Classify.Migrations.down()
  end
end
