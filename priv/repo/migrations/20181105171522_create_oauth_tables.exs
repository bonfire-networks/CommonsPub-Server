defmodule MoodleNet.Repo.Migrations.CreateOauthTables do
  use Ecto.Migration

  def change do
    create table(:oauth_apps) do
      add :client_name, :text
      add :redirect_uris, :text
      add :scopes, :text
      add :website, :text
      add :client_id, :text
      add :client_secret, :text

      timestamps()
    end

    create table(:ooauth_authorizations) do
      add :user_id, references("accounts_users", on_delete: :delete_all, on_update: :update_all), null: false
      add :app_id, references("oauth_apps", on_delete: :delete_all, on_update: :update_all), null: false
      add :token, :text, null: false
      add :valid_until, :naive_datetime_usec, null: false
      add :used, :boolean, default: false, null: false

      timestamps()
    end

    create table(:ooauth_tokens) do
      add :user_id, references("accounts_users", on_delete: :delete_all, on_update: :update_all), null: false
      add :app_id, references("oauth_apps", on_delete: :delete_all, on_update: :update_all), null: false
      add :token, :text, null: false
      add :refresh_token, :text, null: false
      add :valid_until, :naive_datetime_usec, null: false
      add :used, :boolean, default: false, null: false

      timestamps()
    end
  end
end
