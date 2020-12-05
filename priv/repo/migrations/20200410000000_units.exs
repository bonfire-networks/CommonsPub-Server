defmodule CommonsPub.Repo.Migrations.Units do
  use Ecto.Migration

  def change do
    Bonfire.Quantities.Migrations.change()
  end
end
