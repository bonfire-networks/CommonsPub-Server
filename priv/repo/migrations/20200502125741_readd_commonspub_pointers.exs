defmodule MoodleNet.Repo.Migrations.ReaddCommonspubPointers do
  use Ecto.Migration

  def up do

    Geolocation.Migrations.add_pointer()

    Measurement.Migrations.add_pointer()

  end

  def down do

    MoodleNet.ReleaseTasks.remove_meta_table("geolocation")

    MoodleNet.ReleaseTasks.remove_meta_table("measurement")
    MoodleNet.ReleaseTasks.remove_meta_table("measurement_unit")

  end

end
