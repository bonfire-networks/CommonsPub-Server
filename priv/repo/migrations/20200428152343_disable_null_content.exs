defmodule MoodleNet.Repo.Migrations.DisableNullContent do
  use Ecto.Migration

  def up do
    :ok = execute "alter table mn_resource alter column content_id set not null"
  end

  def down do
    :ok = execute "alter table mn_resource alter column content_id set null;"
  end
end
