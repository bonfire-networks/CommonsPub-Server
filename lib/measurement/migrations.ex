defmodule Measurement.Migrations do
  use Ecto.Migration
  alias MoodleNet.Repo

  @meta_tables [] ++ ~w(measurement_unit measurement)

  def change do
    create table(:measurement_unit) do

      add :label, :string
      add :symbol, :string

      add :community_id, references("mn_community", on_delete: :delete_all)
      add :creator_id, references("mn_user", on_delete: :nilify_all)

      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      add :disabled_at, :timestamptz

      timestamps(inserted_at: false, type: :utc_datetime_usec)

    end

  end

  def change_measure do
    create table(:measurement) do

      add :hasNumericalValue, :float

      add :unit_id, references("measurement_unit", on_delete: :delete_all)
      add :creator_id, references("mn_user", on_delete: :nilify_all)

      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      add :disabled_at, :timestamptz

      timestamps(inserted_at: false, type: :utc_datetime_usec)

    end

  end

  def rename_measure_and_fields(:up) do
    MoodleNet.Meta.Migration.remove_meta_table("measurement")

    rename table(:measurement), to: table(:measurement_measure)

    flush() # make sure rename happens first

    :ok = execute("""
    alter table measurement_measure
    rename column "hasNumericalValue" to has_numerical_value;
    """)

    MoodleNet.Meta.Migration.insert_meta_table("measurement_measure")
  end

  def rename_measure_and_fields(:down) do
    MoodleNet.Meta.Migration.remove_meta_table("measurement_measure")

    rename table(:measurement_measure), to: table(:measurement)

    :ok = execute("""
    alter table measurement
    rename column has_numerical_value to "hasNumericalValue";
    """)

    MoodleNet.Meta.Migration.insert_meta_table("measurement")
  end

  def add_pointer do
    for table <- @meta_tables, do: MoodleNet.Meta.Migration.insert_meta_table(table)
  end
end
