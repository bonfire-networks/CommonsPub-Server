defmodule CommonsPub.Repo.Migrations.Profile do
  use Ecto.Migration
  # import Pointers.Migration

  def up(index_opts \\ []),
    do: CommonsPub.Profiles.Migrations.migrate(index_opts, :up)

  def down(index_opts \\ []),
    do: CommonsPub.Profiles.Migrations.migrate(index_opts, :down)
end
