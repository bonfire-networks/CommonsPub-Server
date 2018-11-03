defmodule MoodleNet.Repo.Migrations.AddListFollowIndex do
  use Ecto.Migration

  def change do
    create index(:lists, [:following])
  end
end
