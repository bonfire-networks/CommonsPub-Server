defmodule MoodleNet.Repo.Migrations.AddUploadTable do
  use Ecto.Migration

  def change do
    create table(:mn_upload) do
      add :preview_id, references("mn_upload", on_delete: :delete_all)
      add :uploader_id, references("mn_actor", on_delete: :nilify_all)
      add :path, :string
      add :media_type, :string
      add :metadata, :jsonb
      add :published_at, :timestamptz
      timestamps(type: :utc_datetime_usec)
    end
  end
end
