defmodule MoodleNet.Repo.Migrations.RenameMeasureAndFields do
  use Ecto.Migration

  def up do
    Measurement.Migrations.rename_measure_and_fields(:up)
  end

  def down do
    Measurement.Migrations.rename_measure_and_fields(:down)
  end
end
