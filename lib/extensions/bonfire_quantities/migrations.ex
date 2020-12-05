defmodule Bonfire.Quantities.Migrations do
  use Ecto.Migration
  import Pointers.Migration

  alias Measurement

  def unit_table(), do: Bonfire.Quantities.Unit.__schema__(:source)
  def measure_table(), do: Bonfire.Quantities.Measure.__schema__(:source)

  def change do
    create_pointable_table(Bonfire.Quantities.Unit) do
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
    create_pointable_table(Bonfire.Quantities.Measure) do
      add(:has_numerical_value, :float)

      add(:unit_id, strong_pointer(Bonfire.Quantities.Unit), null: false)
      add(:creator_id, references("mn_user", on_delete: :nilify_all))

      add(:published_at, :timestamptz)
      add(:deleted_at, :timestamptz)
      add(:disabled_at, :timestamptz)

      timestamps(inserted_at: false, type: :utc_datetime_usec)
    end
  end
end
