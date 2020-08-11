defmodule MoodleNet.Repo.Migrations.VF.Proposal do
  use Ecto.Migration

  def change do
    ValueFlows.Proposal.Migrations.change_proposal()
  end
end
