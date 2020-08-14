defmodule MoodleNet.Repo.Migrations.TaxonomyCategory do
  use Ecto.Migration

  def change do
    Taxonomy.Migrations.add_category()
  end
end
