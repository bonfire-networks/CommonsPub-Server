defmodule ValueFlows.Geolocation do

  use MoodleNet.Common.Schema
  # import MoodleNet.Common.Changeset, only: [validate_email_domain: 2]
  alias Ecto.Changeset

  table_schema "vf_spatial_things" do
    field :name, :string
    # field :lat, :float # TODO: turn into virtual fields based on `point`
    # field :long, :float
    field :point, Geo.PostGIS.Geometry
    field :alt, :float # altitude
    field :mappable_address, :string
    field :note, :string

    timestamps()
  end

  @doc false
  def changeset(geolocation, attrs) do
    geolocation
    |> cast(attrs, [:name, :note, :mappable_address, :point,:alt])
    |> validate_required([:name, :note, :mappable_address, :point, :alt])
  end


  # define migrations for each change to this schema below, and make sure to include the migration function(s) 
  # in migrations.ex in the exact order in which schema changes were done

  use Ecto.Migration

  def change do
    create table(:vf_spatial_things) do
      add :name, :string
      add :note, :text
      add :mappable_address, :string
      add :point, :point
      # add :lat, :float
      # add :long, :float
      add :alt, :float

      timestamps()
    end

  end
end
