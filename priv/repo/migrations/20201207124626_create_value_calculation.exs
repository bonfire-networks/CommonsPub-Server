defmodule CommonsPub.Repo.Migrations.CreateValueCalculation do
  use Ecto.Migration

  def up, do: ValueFlows.ValueCalculation.Migrations.up()
  def down, do: ValueFlows.ValueCalculation.Migrations.down()
end
