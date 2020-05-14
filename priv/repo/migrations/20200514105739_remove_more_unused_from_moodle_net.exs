defmodule MoodleNet.Repo.Migrations.RemoveMoreUnusedFromMoodleNet do
  use Ecto.Migration

  def up do

    Organisation.Migrations.down()

  end

  def down do

    Organisation.Migrations.up()

  end

end
