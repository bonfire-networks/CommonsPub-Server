defmodule MoodleNet.Repo.Migrations.AddExtraInfos do
  use Ecto.Migration

  def change do

    alter table("mn_community") do
      add :extra_info, :map
    end

    alter table("mn_collection") do
      add :extra_info, :map
    end

    alter table("mn_resource") do
      add :extra_info, :map
    end

  end
end
