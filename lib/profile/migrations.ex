defmodule Profile.Migrations do
  use Ecto.Migration
  import Pointers.Migration

  # @meta_tables [] ++ ~w(profile)

  def up do
    # a profile is a group actor that is home to resources
    create_mixin_table(:profile) do
      add(:name, :string)
      add(:summary, :text)
      add(:extra_info, :map)
      add(:icon_id, references(:mn_content))
      add(:image_id, references(:mn_content))
      # add :primary_language_id, references("languages", on_delete: :nilify_all)
      add(:creator_id, references("mn_user", on_delete: :nilify_all))
      add(:published_at, :timestamptz)
      add(:deleted_at, :timestamptz)
      add(:disabled_at, :timestamptz)
      # timestamps(inserted_at: false, type: :utc_datetime_usec)
    end

    # create_if_not_exists(index(:profile, :updated_at))
    create_if_not_exists(index(:profile, :creator_id))
    # create_if_not_exists index(:profile, :primary_language_id)
  end

  def down do
    # drop_if_exists(index(:profile, :updated_at))
    drop_if_exists(index(:profile, :creator_id))
    drop_if_exists(index(:profile, :primary_language_id))
    drop_mixin_table(:profile)
  end
end
