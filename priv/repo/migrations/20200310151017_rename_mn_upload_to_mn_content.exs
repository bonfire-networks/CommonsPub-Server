defmodule MoodleNet.Repo.Migrations.RenameMnUploadToMnContent do
  use Ecto.Migration
  import Ecto.Query
  alias MoodleNet.Repo

  @moduledoc """
  Inverts the relationship between the context used by an upload and the upload itself.

  Previously: upload -> item (of pointer)
  Now: item (of pointer) -> upload
  """

  def up do

    :ok = execute "delete from mn_upload" # clean up old uploads - may cause data loss

    rename table(:mn_upload), to: table(:mn_content)

    # change plain URL's to reference uploads
    alter table(:mn_user) do
      add :icon_id, references(:mn_content)
      add :image_id, references(:mn_content)
      remove :icon
      remove :image
    end

    alter table(:mn_community) do
      add :icon_id, references(:mn_content)
      add :image_id, references(:mn_content)
      remove :icon
      remove :image
    end

    alter table(:mn_collection) do
      add :icon_id, references(:mn_content)
      remove :icon
    end

    alter table(:mn_resource) do
      add :icon_id, references(:mn_content)
      add :content_id, references(:mn_content)
      remove :url
      remove :icon
    end

    create table(:mn_content_upload) do
      add :path, :string, null: false
      add :size, :integer, null: false
    end

    create table(:mn_content_mirror) do
      add :url, :string, null: false
    end

    alter table(:mn_content) do
      add :content_upload_id, references(:mn_content_upload, on_delete: :delete_all)
      add :content_mirror_id, references(:mn_content_mirror, on_delete: :delete_all)
      remove :parent_id
      remove :path
      remove :size
    end

    # add constraint to forbid neither references set
    create constraint(
      "mn_content",
      :mirror_or_upload_must_be_set,
      check: "content_mirror_id is not null or content_upload_id is not null"
    )

    # add constraint to forbid both references set
    create constraint(
      "mn_content",
      :mirror_or_upload_must_set_only_one,
      check: "content_mirror_id is null or content_upload_id is null"
    )
  end
end
