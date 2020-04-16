defmodule ValueFlows.Measurement.Migrations do
  use Ecto.Migration

  def change do
    create table(:vf_unit) do

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
    create table(:vf_measure) do

      add :hasNumericalValue, :float

      add :unit_id, references("vf_unit", on_delete: :delete_all)
      add :creator_id, references("mn_user", on_delete: :nilify_all)

      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      add :disabled_at, :timestamptz

      timestamps(inserted_at: false, type: :utc_datetime_usec)

    end

  end
end
