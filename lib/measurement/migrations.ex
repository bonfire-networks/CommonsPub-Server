defmodule Measurement.Migrations do
  use Ecto.Migration
  alias MoodleNet.Repo

  @meta_tables [] ++ ~w(measurement_unit)

  def change do
    create table(:measurement_unit) do
      add :label, :string
      add :symbol, :string

      add :context_id, references("mn_pointer", on_delete: :delete_all)
      add :creator_id, references("mn_user", on_delete: :nilify_all)

      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      add :disabled_at, :timestamptz

      timestamps(inserted_at: false, type: :utc_datetime_usec)

    end
  end

  def change_measure do
    create table(:measurement_measure) do

      add :has_numerical_value, :float

      add :unit_id, references("measurement_unit", on_delete: :delete_all)
      add :creator_id, references("mn_user", on_delete: :nilify_all)

      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      add :disabled_at, :timestamptz

      timestamps(inserted_at: false, type: :utc_datetime_usec)
    end

  end

  def add_pointer do
    for table <- @meta_tables, do: MoodleNet.Meta.Migration.insert_meta_table(table)
  end
end
