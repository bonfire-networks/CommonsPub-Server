defmodule MoodleNet.Repo.Migrations.CitextAccessTables do
  use Ecto.Migration

  def up do
    :ok = execute """
    ALTER TABLE mn_access_register_email
    ALTER COLUMN email
    TYPE citext
    """

    :ok = execute """
    ALTER TABLE mn_access_register_email_domain
    ALTER COLUMN domain
    TYPE citext
    """
  end

  def down do
    :ok = execute """
    ALTER TABLE mn_access_register_email
    ALTER COLUMN email
    TYPE text
    """

    :ok = execute """
    ALTER TABLE mn_access_register_email_domain
    ALTER COLUMN domain
    TYPE text
    """
  end
end
