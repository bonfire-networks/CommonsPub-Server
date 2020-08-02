defmodule MoodleNet.Repo.Migrations.CommonsPub.Character do
  use Ecto.Migration
  import Pointers.Migration

  # cheated by moving it earlier so we can use it in older migrations

  # FIXME
  def change(index_opts \\ []),
    do: CommonsPub.Character.Migrations.migrate(index_opts, direction())

  # do: nil
end
