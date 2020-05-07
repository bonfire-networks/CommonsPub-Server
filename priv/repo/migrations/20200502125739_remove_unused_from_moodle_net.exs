defmodule MoodleNet.Repo.Migrations.RemoveUnusedFromMoodleNet do
  use Ecto.Migration

  def up do

    # Locales.Migrations.down()

    # Taxonomy.Migrations.down()

    # MoodleNet.ReleaseTasks.remove_meta_table("vf_spatial_things")

    # MoodleNet.ReleaseTasks.remove_meta_table("vf_measure")
    # MoodleNet.ReleaseTasks.remove_meta_table("vf_unit")

    # # Geolocation
    # :ok = execute "drop table if exists vf_spatial_things cascade"

    # # Measurement
    # :ok = execute "drop table if exists vf_measure cascade"
    # :ok = execute "drop table if exists vf_unit cascade"



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
