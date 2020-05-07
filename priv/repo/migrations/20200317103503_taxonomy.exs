defmodule MoodleNet.Repo.Migrations.Taxonomy do
  use Ecto.Migration

  def up do

    Taxonomy.Migrations.up()

  end

  def down do

    Taxonomy.Migrations.down()

  end

end
