defmodule CommonsPub.Repo.Migrations.VF.ResourceEventProcess do
  use Ecto.Migration

  def up do
    ValueFlows.Knowledge.ResourceSpecification.Migrations.up()
    ValueFlows.Knowledge.ProcessSpecification.Migrations.up()
    ValueFlows.Observation.EconomicResource.Migrations.up()
    ValueFlows.Observation.Process.Migrations.up()
    ValueFlows.Observation.EconomicEvent.Migrations.up()
  end

  def down do
    ValueFlows.Knowledge.ResourceSpecification.Migrations.down()
    ValueFlows.Knowledge.ProcessSpecification.Migrations.down()
    ValueFlows.Observation.EconomicResource.Migrations.down()
    ValueFlows.Observation.Process.Migrations.down()
    ValueFlows.Observation.EconomicEvent.Migrations.down()
  end
end
