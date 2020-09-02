defmodule CommonsPub.Repo.Migrations.ChangeMnContentVarcharToText do
  use Ecto.Migration

  def up do
    alter table(:mn_content) do
      modify(:media_type, :text)
    end

    alter table(:mn_content_upload) do
      modify(:path, :text)
    end

    alter table(:mn_content_mirror) do
      modify(:url, :text)
    end
  end

  def down do
    alter table(:mn_content) do
      modify(:media_type, :string)
    end

    alter table(:mn_content_upload) do
      modify(:path, :string)
    end

    alter table(:mn_content_mirror) do
      modify(:url, :string)
    end
  end
end
