defmodule MoodleNet.Repo.Migrations.ChangeAccessTables do
  use Ecto.Migration

  def change do
    alter table(:mn_access_register_email) do
      modify :email, :citext
    end

    alter table(:mn_access_register_email_domain) do
      modify :domain, :citext
    end
  end
end
