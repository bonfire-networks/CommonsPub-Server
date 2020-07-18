defmodule MoodleNet.Repo.Migrations.AddThreadTitle do
  use Ecto.Migration

  def change do
    alter table("mn_thread") do
      add(:name, :string)
    end

    alter table("mn_comment") do
      add(:name, :string)
    end
  end
end
