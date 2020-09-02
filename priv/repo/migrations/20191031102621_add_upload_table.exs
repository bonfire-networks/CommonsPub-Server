# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Repo.Migrations.AddUploadTable do
  use Ecto.Migration
  import Pointers.Migration

  def up do
    create table(:mn_upload) do
      add(:parent_id, weak_pointer(), null: true, null: false)
      add(:preview_id, references("mn_upload", on_delete: :delete_all))
      add(:uploader_id, references("mn_user", on_delete: :nilify_all))
      add(:path, :string, null: false)
      add(:media_type, :string, null: false)
      add(:size, :integer, null: false)
      add(:metadata, :jsonb)
      add(:published_at, :timestamptz)
      add(:deleted_at, :timestamptz)
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create(index(:mn_upload, :path, where: "deleted_at is null"))
  end

  def down do
    # fixme - blocked by RenameMnUploadToMnContent
  end
end
