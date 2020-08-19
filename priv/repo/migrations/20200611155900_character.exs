defmodule MoodleNet.Repo.Migrations.CommonsPub.Character do
  use Ecto.Migration
  import Pointers.Migration

  # FIXME
  def change(index_opts \\ []),
    do: CommonsPub.Character.Migrations.migrate(index_opts, direction())

  # do: nil
end
