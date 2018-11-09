defmodule MoodleNet.Repo.Migrations.CreateAccountTables do
  use ActivityPub.Migration

  def change do
    create table(:accounts_users) do
      add :email, :citext, null: false
      add_foreign_key(:primary_actor_id, "activity_pub_actors")

      timestamps()
    end
    create(unique_index("accounts_users", :email))

    create table(:accounts_password_auths) do
      add_foreign_key(:user_id, "accounts_users")
      add :password_hash, :text, null: false

      timestamps()
    end
    create(unique_index("accounts_password_auths", :user_id))

    create table(:accounts_reset_password_token) do
      add_foreign_key(:password_auth_id, "accounts_password_auths")
      add :token, :text, null: false
      add :used, :boolean, null: false, default: false

      timestamps()
    end

    create table(:notifications_notifications) do
      add_foreign_key(:user_id, "accounts_users")
      add :activity_id, references("activity_pub_activities", on_delete: :delete_all, on_update: :update_all), null: false
      add :seen, :boolean, null: false, default: false

      timestamps()
    end
  end
end
