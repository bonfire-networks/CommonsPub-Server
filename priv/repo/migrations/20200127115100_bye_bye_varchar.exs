# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Repo.Migrations.ByeByeVarchar do
  use Ecto.Migration

  def up do
    :ok = execute "alter table mn_resource alter column name type text"
    :ok = execute "alter table mn_resource alter column url type text"
    :ok = execute "alter table mn_resource alter column license type text"
    :ok = execute "alter table mn_resource alter column icon type text"
  end

  def down do
    :ok = execute "alter table mn_resource alter column name type varchar(256)"
    :ok = execute "alter table mn_resource alter column url type varchar(256)"
    :ok = execute "alter table mn_resource alter column license type varchar(256)"
    :ok = execute "alter table mn_resource alter column icon type varchar(256)"
  end
end
