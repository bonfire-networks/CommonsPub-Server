defmodule CommonsPub.Repo.Migrations.Bonfire.Geolocate.Geolocation do
  use Ecto.Migration

  def change do
    Bonfire.Geolocate.Migrations.change()
  end
end
