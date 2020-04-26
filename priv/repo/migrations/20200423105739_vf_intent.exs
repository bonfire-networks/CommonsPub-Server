defmodule MoodleNet.Repo.Migrations.VF.Intent do
  use Ecto.Migration

  def change do
      ValueFlows.Knowledge.Migrations.change_action()
      ValueFlows.Planning.Migrations.change_intent()
  end

end
