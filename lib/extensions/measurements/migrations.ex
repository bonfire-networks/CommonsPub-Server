defmodule Measurement.Migrations do
  use Ecto.Migration
  import Pointers.Migration

  alias Measurement
  alias Measurement

  def change do
    create_pointable_table(Measurement.Unit) do
      add(:label, :string)
      add(:symbol, :string)

      add(:context_id, weak_pointer(), null: true)
      add(:creator_id, references("mn_user", on_delete: :nilify_all))

      add(:published_at, :timestamptz)
      add(:deleted_at, :timestamptz)
      add(:disabled_at, :timestamptz)

      timestamps(inserted_at: false, type: :utc_datetime_usec)
    end
  end

  def change_measure do
    create table(Measurement.Measure) do
      add(:has_numerical_value, :float)

      add(:unit_id, strong_pointer(Measurement.Unit), null: false)
      add(:creator_id, references("mn_user", on_delete: :nilify_all))

      add(:published_at, :timestamptz)
      add(:deleted_at, :timestamptz)
      add(:disabled_at, :timestamptz)

      timestamps(inserted_at: false, type: :utc_datetime_usec)
    end

    create(unique_index(:measurement_measure, [:unit_id, :has_numerical_value]))
  end
end
