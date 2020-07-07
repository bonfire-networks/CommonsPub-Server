defmodule MoodleNet.Repo.Migrations.AddTaggable do
    use Ecto.Migration

    def up do
      # Pointers.Migration.create_main_pointer_trigger_function()
      # flush()
      Tag.Migrations.up()
    end

    def down do
      Tag.Migrations.down()
    end
end
