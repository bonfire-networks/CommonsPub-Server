defmodule MoodleNet.Repo.Migrations.CreateOauthTables do
  use Ecto.Migration

  def change do
    create table(:oauth_apps) do
      add :client_name, :text, null: false
      add :redirect_uri, :text, null: false
      add :scopes, :text
      add :website, :text
      add :client_id, :text, null: false
      add :client_secret, :text

      timestamps()
    end

    create(unique_index(:oauth_apps, :client_id))

    create table(:oauth_authorizations) do
      add :user_id, references("accounts_users", on_delete: :delete_all, on_update: :update_all), null: false
      add :app_id, references("oauth_apps", on_delete: :delete_all, on_update: :update_all), null: false
      add :hash, :text, null: false
      add :valid_until, :naive_datetime_usec, null: false
      add :used, :boolean, default: false, null: false

      timestamps()
    end

    create(index(:oauth_authorizations, :user_id))

    create table(:oauth_tokens) do
      add :user_id, references("accounts_users", on_delete: :delete_all, on_update: :update_all), null: false
      add :app_id, references("oauth_apps", on_delete: :delete_all, on_update: :update_all), null: false
      add :hash, :text, null: false
      add :refresh_hash, :text, null: false
      add :valid_until, :naive_datetime_usec, null: false
      add :used, :boolean, default: false, null: false

      timestamps()
    end

    create(index(:oauth_tokens, :user_id))
  end
end
