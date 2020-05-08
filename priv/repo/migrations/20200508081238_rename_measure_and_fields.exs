defmodule MoodleNet.Repo.Migrations.RenameMeasureAndFields do
  use Ecto.Migration

  def change do
    Measurement.Migrations.rename_measure_and_fields()
  end
end
