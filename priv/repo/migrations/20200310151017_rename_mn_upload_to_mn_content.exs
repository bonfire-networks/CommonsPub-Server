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
    rename table(:mn_upload), to: table(:mn_content)

    # change plain URL's to reference uploads
    alter table(:mn_user) do
      add :icon_id, references(:mn_content)
      add :image_id, references(:mn_content)
    end

    alter table(:mn_community) do
      add :icon_id, references(:mn_content)
      add :image_id, references(:mn_content)
    end

    alter table(:mn_collection) do
      add :icon_id, references(:mn_content)
    end

    alter table(:mn_resource) do
      add :icon_id, references(:mn_content)
      add :content_id, references(:mn_content)
    end

    create table(:mn_content_upload) do
      add :path, :string, null: false
    end

    create table(:mn_content_mirror) do
      add :url, :string, null: false
    end

    alter table(:mn_content) do
      add :content_upload_id, references(:mn_content_upload, on_delete: :delete_all)
      add :content_mirror_id, references(:mn_content_mirror, on_delete: :delete_all)
    end

    # Update parents to reference mn_content (only local files)
    :ok = execute update_uploads_q("mn_user", "icon", "icon_id")
    :ok = execute update_uploads_q("mn_user", "image", "image_id")
    :ok = execute update_uploads_q("mn_community", "image", "image_id")
    :ok = execute update_uploads_q("mn_community", "icon", "icon_id")
    :ok = execute update_uploads_q("mn_collection", "icon", "icon_id")
    :ok = execute update_uploads_q("mn_resource", "icon", "icon_id")
    :ok = execute update_uploads_q("mn_resource", "url", "content_id")

    # Move all items from mn_upload to mn_content_upload
    :ok = execute """
    insert into mn_content_upload (id, path)
    select id, path from mn_content;
    """

    # Update mn_content to reference mn_content_upload
    :ok = execute """
    update mn_content c
    set content_upload_id = cu.id
    from mn_content_upload cu
    where c.path = cu.path;
    """

    # Handle remote URL's
    :ok = execute_mirrors_q("mn_user", "icon", "icon_id")
    :ok = execute_mirrors_q("mn_user", "image", "image_id")
    :ok = execute_mirrors_q("mn_community", "image", "image_id")
    :ok = execute_mirrors_q("mn_community", "icon", "icon_id")
    :ok = execute_mirrors_q("mn_collection", "icon", "icon_id")
    :ok = execute_mirrors_q("mn_resource", "icon", "icon_id")
    :ok = execute_mirrors_q("mn_resource", "url", "content_id")

    flush()

    # TODO: ensure there are no dangling records
    false = repo().exists?(from(c in "mn_content", where: is_nil(c.content_upload_id) and is_nil(c.content_mirror_id)))
    # false = repo().exists?("mn_content_upload")
    # false = repo().exists?("mn_content_mirror")

    # FIXME: add constraint to forbid both or neither references set
    alter table(:mn_content) do
      remove :parent_id
      remove :path
    end

    alter table(:mn_resource) do
      remove :url
      remove :icon
    end

    alter table(:mn_collection) do
      remove :icon
    end

    alter table(:mn_community) do
      remove :icon
      remove :image
    end

    alter table(:mn_user) do
      remove :icon
      remove :image
    end
  end

  def down do
    alter table(:mn_user) do
      add :icon, :string
      add :image, :string
    end

    alter table(:mn_resource) do
      add :url, :string
      add :icon, :string
    end

    alter table(:mn_collection) do
      add :icon, :string
    end

    alter table(:mn_community) do
      add :icon, :string
      add :image, :string
    end

    rename table(:mn_content), to: table(:mn_upload)

    alter table(:mn_upload) do
      add :parent_id, references(:mn_pointer, on_delete: :delete_all), null: false
      add :path, :string, null: false
    end

    # TODO: move over data

    alter table(:mn_upload) do
      remove :content_upload_id
      remove :content_mirror_id
    end
  end

  defp update_uploads_q(table, old_field, new_field) do
    """
    update #{table} x
    set #{new_field} = c.id
    from mn_content c
    where x.id = c.parent_id and x.#{old_field} = c.path;
    """
  end

  defp execute_mirrors_q(table, old_field, new_field) do
    :ok = execute """
    insert into mn_content_mirror (id, url)
    select uuid_generate_v4(), #{old_field} from #{table}
    where #{new_field} is null and #{old_field} is not null;
    """

    :ok = execute """
    insert into mn_content (id, parent_id, content_mirror_id, path, media_type, size, created_at, updated_at)
    select x.id, x.id, cm.id, cm.url, 'application/octet-stream', 0, x.updated_at, x.updated_at from mn_content_mirror cm, #{table} x
    where x.#{old_field} = cm.url;
    """

    :ok = execute """
    update #{table} x
    set #{new_field} = c.id
    from mn_content c
    where x.id = c.parent_id and x.#{old_field} = c.path;
    """
  end
end
