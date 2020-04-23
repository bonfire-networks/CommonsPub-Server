defmodule MoodleNet.Repo.Migrations.Geolocation.Pointer do
    use Ecto.Migration

    def up do
      Geolocation.Migrations.add_pointer()
    end
end
