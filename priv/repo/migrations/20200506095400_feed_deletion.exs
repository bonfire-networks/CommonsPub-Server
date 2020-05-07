defmodule MoodleNet.Repo.Migrations.FeedDeletion do
  use Ecto.Migration

  def change do

    alter table("mn_feed") do
      add :deleted_at, :timestamptz
    end

  end

end
