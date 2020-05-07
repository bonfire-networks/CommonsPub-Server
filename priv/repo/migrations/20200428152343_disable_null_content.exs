defmodule MoodleNet.Repo.Migrations.DisableNullContent do
  use Ecto.Migration

  def up do
    :ok = execute "delete from mn_resource where content_id is null" # clean up - may cause data loss
    :ok = execute "alter table mn_resource alter column content_id set not null"
  end

  def down do
    :ok = execute "alter table mn_resource alter column content_id set null;"
  end
end
