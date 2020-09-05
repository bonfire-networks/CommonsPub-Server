defmodule CommonsPub.Repo.Migrations.DisableNullContent do
  use Ecto.Migration

  def up do
    # clean up - may cause data loss
    :ok = execute("delete from mn_resource where content_id is null")
    :ok = execute("alter table mn_resource alter column content_id set not null")
  end

  def down do
    # :ok = execute "alter table mn_resource alter column content_id set null;"
  end
end
