# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Repo.Migrations.ByeByeVarchar do
  use Ecto.Migration

  def up do
    :ok = execute("alter table mn_resource alter column name type text")
    :ok = execute("alter table mn_resource alter column url type text")
    :ok = execute("alter table mn_resource alter column license type text")
    :ok = execute("alter table mn_resource alter column icon type text")
  end

  def down do
    # fixme - blocked by RenameMnUploadToMnContent
    # :ok = execute "alter table mn_resource alter column name type varchar(256)"
    # :ok = execute "alter table mn_resource alter column url type varchar(256)"
    # :ok = execute "alter table mn_resource alter column license type varchar(256)"
    # :ok = execute "alter table mn_resource alter column icon type varchar(256)"
  end
end
