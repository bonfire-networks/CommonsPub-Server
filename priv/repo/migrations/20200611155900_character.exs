defmodule MoodleNet.Repo.Migrations.Character do
  use Ecto.Migration
  import Pointers.Migration

  def change(index_opts \\ []),
    # do Character.Migrations.migrate(index_opts, direction()) # FIXME
    do: nil
end
