defmodule MoodleNet.Repo.Migrations.Character do
  use Ecto.Migration
  import Pointers.Migration

  # FIXME
  def change(index_opts \\ []), do: Character.Migrations.migrate(index_opts, direction())
  # do: nil
end
