defmodule CommonsPub.Repo.Migrations.Units.Measure do
  use Ecto.Migration

  def change do
    Bonfire.Quantify.Migrations.change_measure()
  end
end
