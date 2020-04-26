defmodule MoodleNet.Repo.Migrations.Units do
    use Ecto.Migration

    def change do
        Measurement.Migrations.change()
    end

end
