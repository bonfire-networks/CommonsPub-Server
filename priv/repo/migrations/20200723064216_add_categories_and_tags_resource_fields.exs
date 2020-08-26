defmodule MoodleNet.Repo.Migrations.AddCategoriesAndTagsResourceFields do
  use Ecto.Migration

  def change do
    alter table("mn_resource") do
      add(:subject, :string)
      add(:level, :string)
      add(:language, :string)
      add(:type, :string)
    end
  end
end
