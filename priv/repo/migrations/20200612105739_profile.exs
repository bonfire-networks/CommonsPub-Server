defmodule MoodleNet.Repo.Migrations.Profile do
  use Ecto.Migration
  import Pointers.Migration

  def change(index_opts \\ []),
    # do: Profile.Migrations.migrate(index_opts, direction()) # FIXME
end
