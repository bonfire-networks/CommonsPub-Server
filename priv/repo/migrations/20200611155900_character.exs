defmodule MoodleNet.Repo.Migrations.CommonsPub.Character do
  use Ecto.Migration
  # import Pointers.Migration

  def up(index_opts \\ []),
    do: CommonsPub.Character.Migrations.migrate(index_opts, :up)

  def down(index_opts \\ []),
    do: CommonsPub.Character.Migrations.migrate(index_opts, :down)
end
