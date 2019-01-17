defmodule MoodleNet.Repo.Migrations.WhitelistEmails do
  use Ecto.Migration

  def change do
    create table(:accounts_whitelist_emails, primary_key: false) do
      add :email, :citext, null: false, primary_key: true
    end
  end
end
