defmodule MoodleNet.Repo.Migrations.Measure do
  use Ecto.Migration

  def change do
    ValueFlows.Measurement.Migrations.change_measure()
end
end
