defmodule CommonsPub.Repo.Migrations.Characters do
  use Ecto.Migration

  # cheated by moving this earlier so we can use Character in older migrations

  def change(index_opts \\ []),
    do: CommonsPub.Characters.Migrations.migrate(index_opts, direction())
end
