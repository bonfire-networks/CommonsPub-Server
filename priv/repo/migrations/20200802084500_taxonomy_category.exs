defmodule CommonsPub.Repo.Migrations.TaxonomyCategory do
  use Ecto.Migration

  def up do
    Taxonomy.Migrations.add_category()
  end

  def down do
    # todo
  end
end
