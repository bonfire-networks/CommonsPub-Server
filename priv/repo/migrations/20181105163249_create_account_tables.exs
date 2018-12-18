defmodule MoodleNet.Repo.Migrations.CreateAccountTables do
  use ActivityPub.Migration

  def change do
    create table(:accounts_users) do
      add(:email, :citext, null: false)
      add_foreign_key(:primary_actor_id, "activity_pub_actor_aspects", column: :local_id)

      timestamps()
    end

    create(unique_index("accounts_users", :email))

    create table(:accounts_password_auths) do
      add(
        :user_id,
        references("accounts_users", type: :bigint, on_update: :update_all, on_delete: :delete_all),
        null: false
      )

      add(:password_hash, :text, null: false)

      timestamps()
    end

    create(unique_index("accounts_password_auths", :user_id))

    create table(:accounts_reset_password_token) do
      add(
        :password_auth_id,
        references("accounts_password_auths", type: :bigint, on_update: :update_all, on_delete: :delete_all),
        null: false
      )
      add(:token, :text, null: false)
      add(:used, :boolean, null: false, default: false)

      timestamps()
    end
  end
end
