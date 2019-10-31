defmodule MoodleNet.Repo.Migrations.AddUploadTable do
  use Ecto.Migration

  def change do
    create table(:mn_upload) do
      add :parent_id, references("mn_meta_pointer", on_delete: :delete_all), null: false
      add :preview_id, references("mn_upload", on_delete: :delete_all)
      add :uploader_id, references("mn_actor", on_delete: :nilify_all)
      add :path, :string, null: false
      add :media_type, :string, null: false
      add :metadata, :jsonb
      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      timestamps(type: :utc_datetime_usec)
    end

    create index(:mn_upload, :path, where: "deleted_at is null")
  end
end
