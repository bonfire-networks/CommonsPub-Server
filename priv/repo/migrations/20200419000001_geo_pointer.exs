defmodule MoodleNet.Repo.Migrations.GeolocationPointer do
    use Ecto.Migration

    def change do
      Geolocation.Migrations.add_pointer()
    end
end
