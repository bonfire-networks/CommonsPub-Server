defmodule MoodleNet.Repo.Migrations.VF.Intent.Pointer do
  use Ecto.Migration

  def up do
      ValueFlows.Planning.Migrations.add_intent_pointer()
  end

  def down do
    MoodleNet.ReleaseTasks.remove_meta_table("vf_intent")
  end


end
