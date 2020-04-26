defmodule MoodleNet.Repo.Migrations.Units.Measure do
  use Ecto.Migration

  def change do
    Measurement.Migrations.change_measure()
  end
end
