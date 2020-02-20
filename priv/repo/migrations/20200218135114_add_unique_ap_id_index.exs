defmodule MoodleNet.Repo.Migrations.AppUniqueApIdIndex do
  use Ecto.Migration

  def change do
    drop index(:ap_object, ["(data->>'id')"])
    create unique_index(:ap_object, ["(data->>'id')"])
  end
end
