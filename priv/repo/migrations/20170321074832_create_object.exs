defmodule MoodleNet.Repo.Migrations.CreateMoodleNet.Object do
  use Ecto.Migration

  def change do
    create table(:objects) do
      add :data, :map

      timestamps()
    end

  end
end
