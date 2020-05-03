defmodule MoodleNet.Repo.Migrations.RemoveUnusedFromMoodleNet do
  use Ecto.Migration

  def up do

    # Locales.Migrations.down()

    # Taxonomy.Migrations.down()

    # Geolocation
    drop_if_exists table("vf_spatial_things")

    # Measurement
    drop_if_exists table("vf_measure")
    drop_if_exists table("vf_unit")

    MoodleNet.ReleaseTasks.remove_meta_table("vf_spatial_things")

    MoodleNet.ReleaseTasks.remove_meta_table("vf_measure")
    MoodleNet.ReleaseTasks.remove_meta_table("vf_unit")

  end

  def down do

    # Locales.Migrations.up()

    # Taxonomy.Migrations.up()

    # Geolocation.Migrations.change()
    # Geolocation.Migrations.add_pointer()

    # Measurement.Migrations.change()
    # Measurement.Migrations.change_measure()
    # Measurement.Migrations.add_pointer()

  end

end
