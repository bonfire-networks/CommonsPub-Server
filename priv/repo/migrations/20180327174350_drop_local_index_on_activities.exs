defmodule MoodleNet.Repo.Migrations.DropLocalIndexOnActivities do
  use Ecto.Migration

  def change do
    drop index(:users, [:local])
  end
end
