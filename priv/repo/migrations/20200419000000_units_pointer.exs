defmodule MoodleNet.Repo.Migrations.Units.Pointer do
    use Ecto.Migration

    def up do
      Measurement.Migrations.add_pointer()
    end

    def down do
      MoodleNet.ReleaseTasks.remove_meta_table("measurement_units")
    end
end
