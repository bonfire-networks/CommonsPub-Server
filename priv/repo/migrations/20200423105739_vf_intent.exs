defmodule MoodleNet.Repo.Migrations.VF.Intent do
  use Ecto.Migration

  def up do
    # ValueFlows.Knowledge.Migrations.change_action()
    ValueFlows.Planning.Migrations.up()
  end

  def down do
    ValueFlows.Planning.Migrations.down()
  end

end
