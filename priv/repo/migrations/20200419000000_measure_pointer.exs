defmodule MoodleNet.Repo.Migrations.MeasurePointer do
    use Ecto.Migration

    def change do
      ValueFlows.Measurement.Migrations.add_pointer()
    end
end
