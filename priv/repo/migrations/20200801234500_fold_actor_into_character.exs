defmodule CommonsPub.Repo.Migrations.FoldActorIntoCharacter do
  use Ecto.Migration

  def change do
    CommonsPub.Characters.Migrations.merge_with_actor()
  end
end
