defmodule MoodleNet.Repo.Migrations.AddApIdIndexToObjects do
  use Ecto.Migration

  def change do
    create index(:ap_object, ["(data->>'id')"])
  end
end
