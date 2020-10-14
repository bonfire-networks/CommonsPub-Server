defmodule CommonsPub.Repo.Migrations.VF.IntentRefs do
  use Ecto.Migration

  def change do
    ValueFlows.Planning.Intent.Migrations.add_references()
  end

end
