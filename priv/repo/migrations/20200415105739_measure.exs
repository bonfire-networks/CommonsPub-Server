defmodule MoodleNet.Repo.Migrations.Measure do
  use Ecto.Migration

  def change do
    ValueFlows.Migrations.change_measure()
end
end
