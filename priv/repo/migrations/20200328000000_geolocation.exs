defmodule MoodleNet.Repo.Migrations.Geolocation do
    use Ecto.Migration

    def change do
        Geolocation.Migrations.change()
    end

end
