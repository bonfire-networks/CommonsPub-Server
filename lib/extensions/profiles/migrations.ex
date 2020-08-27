defmodule CommonsPub.Profile.Migrations do
  import Ecto.Migration
  import Pointers.Migration

  defp table_name(), do: CommonsPub.Profile.__schema__(:source)

  def migrate(index_opts, :up) do
    # a profile is a group actor that is home to resources
    create_mixin_table(CommonsPub.Profile) do
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
    create_if_not_exists(index(table_name(), :creator_id, index_opts))
    # create_if_not_exists index(:profile, :primary_language_id)
  end

  def migrate(index_opts, :down) do
    # drop_if_exists(index(:profile, :updated_at))
    drop_if_exists(index(table_name(), :creator_id, index_opts))
    drop_if_exists(index(table_name(), :primary_language_id, index_opts))
    drop_mixin_table(CommonsPub.Profile)
  end
end
