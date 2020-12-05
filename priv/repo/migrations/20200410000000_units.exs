defmodule CommonsPub.Repo.Migrations.Units do
  use Ecto.Migration

  def change do
    Bonfire.Quantify.Migrations.change()
  end
end
