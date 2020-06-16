defmodule MoodleNet.Repo.Migrations.AddCategoriesAndTagsResourceFields do
  use Ecto.Migration

  def change do
      alter table("mn_resource") do
      add :categories, {:array, :string}
      add :tags, {:array, :string}
    end
  end
end
