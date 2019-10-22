defmodule MoodleNet.Repo.Migrations.AddKeysField do
  use Ecto.Migration

  def change do
    alter table(:activity_pub_actor_aspects) do
      add :keys, :text
    end
  end
end
