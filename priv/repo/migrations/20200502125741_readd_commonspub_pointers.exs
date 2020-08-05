defmodule MoodleNet.Repo.Migrations.ReaddCommonspubPointers do
  use Ecto.Migration

  def up do
    # Geolocation.Migrations.add_pointer()

    # Measurement.Migrations.add_pointer()
  end

  def down do
    CommonsPub.ReleaseTasks.remove_meta_table("geolocation")

    CommonsPub.ReleaseTasks.remove_meta_table("measurement")
    CommonsPub.ReleaseTasks.remove_meta_table("measurement_unit")
  end
end
