defmodule CommonsPub.Repo.Migrations.GeolocationField do
  use Ecto.Migration

    defp table_name(), do: Geolocation.__schema__(:source)

  def change do
    add_geolocation()

    Geolocation.Migrations.add_geolocation()
  end

  def add_geolocation do
    alter table(CommonsPub.Users.User) do
      add_if_not_exists(:geolocation_id, references(table_name(), on_delete: :nilify_all))
    end
  end
end
