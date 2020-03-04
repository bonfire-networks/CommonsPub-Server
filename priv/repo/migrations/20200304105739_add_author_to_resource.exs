defmodule MoodleNet.Repo.Migrations.AddAuthorToResource do
  use Ecto.Migration

  def change do
    alter table("mn_resource") do
      add :author, :string
    end
  end
end
