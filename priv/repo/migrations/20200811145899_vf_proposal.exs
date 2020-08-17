defmodule MoodleNet.Repo.Migrations.VF.Proposal do
  use Ecto.Migration

  def up do
    ValueFlows.Proposal.Migrations.up()
  end

  def down do
    ValueFlows.Proposal.Migrations.down()
  end
end
