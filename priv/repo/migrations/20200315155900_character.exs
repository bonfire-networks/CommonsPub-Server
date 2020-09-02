defmodule CommonsPub.Repo.Migrations.CommonsPub.Character do
  use Ecto.Migration

  # cheated by moving this earlier so we can use Character in older migrations

  def change(index_opts \\ []),
    do: CommonsPub.Character.Migrations.migrate(index_opts, direction())
end
