defmodule CommonsPub.Repo.Migrations.TaxonomyCategory do
  use Ecto.Migration

  def up do
    Bonfire.TaxonomySeeder.Migrations.add_category()
  end

  def down do
    # todo
  end
end
