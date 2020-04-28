defmodule MoodleNet.Repo.Migrations.Units.Pointer do
    use Ecto.Migration

    def up do
      Measurement.Migrations.add_pointer()
    end
end
