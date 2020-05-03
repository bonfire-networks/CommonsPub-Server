defmodule MoodleNet.Repo.Migrations.Geolocation.Pointer do
    use Ecto.Migration

    def up do
      Geolocation.Migrations.add_pointer()
    end

    def down do
      MoodleNet.ReleaseTasks.remove_meta_table("geolocation")
    end
end
