defmodule CommonsPub.Repo.Migrations.VF.Intent do
  use Ecto.Migration

  def up do
    # ValueFlows.Knowledge.Migrations.change_action()
    ValueFlows.Planning.Intent.Migrations.up()
  end

  def down do
    ValueFlows.Planning.Intent.Migrations.down()
  end
end
