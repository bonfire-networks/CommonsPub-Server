defmodule MoodleNet.Repo.Migrations.ReaddCommonspubExtensions do
  use Ecto.Migration

  def change do

    Geolocation.Migrations.change()

    Measurement.Migrations.change()
    Measurement.Migrations.change_measure()

  end

  def down do

    # Geolocation
    drop_if_exists table("geolocation")

    # Measurement
    drop_if_exists table("measurement")
    drop_if_exists table("measurement_unit")

  end

end
