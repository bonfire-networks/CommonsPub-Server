defmodule MoodleNet.Repo.Migrations.CreateAccountTables do
  use Ecto.Migration

  def change do
    create table(:accounts_users) do
      add :primary_actor_id, references("activity_pub_actors", on_delete: :delete_all, on_update: :update_all), null: false
      add :following_count, :integer, null: false, default: 0

      timestamps()
    end

    create table(:accounts_password_auth) do
      add :user_id, references("accounts_users", on_delete: :delete_all, on_update: :update_all), null: false
      add :email, :citext, null: false
      add :password_hash, :text, null: false

      timestamps()
    end

    create(unique_index("accounts_password_auth", :email))

    create table(:accounts_reset_password_token) do
      add :password_auth_id, references("accounts_password_auth", on_delete: :delete_all, on_update: :update_all), null: false
      add :token, :text, null: false
      add :used, :boolean, null: false, default: false

      timestamps()
    end

    create table(:notifications_notifications) do
      add :user_id, references("accounts_users", on_delete: :delete_all, on_update: :update_all), null: false
      add :activity_id, references("activity_pub_activities", on_delete: :delete_all, on_update: :update_all), null: false
      add :seen, :boolean, null: false, default: false

      timestamps()
    end
  end
end
