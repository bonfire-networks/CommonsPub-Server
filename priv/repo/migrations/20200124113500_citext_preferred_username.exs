# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Repo.Migrations.CiTextPreferredUsername do
  use Ecto.Migration

  def up do
    :ok =
      execute("""
      CREATE EXTENSION IF NOT EXISTS citext
      """)

    :ok =
      execute("""
      ALTER TABLE mn_actor
      ALTER COLUMN preferred_username
      TYPE citext
      """)
  end

  def down do
    :ok =
      execute("""
      ALTER TABLE mn_actor
      ALTER COLUMN preferred_username
      TYPE text
      """)
  end
end
