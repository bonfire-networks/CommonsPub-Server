defmodule MoodleNet.Repo.Migrations.UserExtraInfo do
  use Ecto.Migration

  def change do
    alter table("mn_user") do
      add :extra_info, :map
    end
  end
end
