defmodule MoodleNet.Repo.Migrations.ReaddCircle do
  use Ecto.Migration

  def up do
    # Pointers.Migration.create_main_pointer_trigger_function()
    # flush()
    Circle.Migrations.up()
  end

  def down do
    Circle.Migrations.down()
  end
end
