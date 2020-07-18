defmodule MoodleNet.Repo.Migrations.TaxonomyExtras do
  use Ecto.Migration

  def up do
    Taxonomy.Migrations.remove_pointer()
  end

  def down do
  end
end
