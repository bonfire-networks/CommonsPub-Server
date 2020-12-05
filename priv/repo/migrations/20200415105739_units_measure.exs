defmodule CommonsPub.Repo.Migrations.Units.Measure do
  use Ecto.Migration

  def change do
    Bonfire.Quantities.Migrations.change_measure()
  end
end
