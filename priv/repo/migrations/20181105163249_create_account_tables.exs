# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Repo.Migrations.CreateAccountTables do
  use ActivityPub.Migration

  def change do
    create table(:accounts_users) do
      add(:email, :citext, null: false)
      add_foreign_key(:actor_id, "activity_pub_actor_aspects", column: :local_id)

      add(:confirmed_at, :utc_datetime)
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

    create table(:accounts_reset_password_tokens) do
      add(
        :user_id,
        references("accounts_users", type: :bigint, on_update: :update_all, on_delete: :delete_all),
        null: false
      )
      add(:token, :text, null: false)

      timestamps(updated_at: false)
    end
    create(unique_index("accounts_reset_password_tokens", :user_id))

    create table(:accounts_email_confirmation_tokens) do
      add(
        :user_id,
        references("accounts_users", type: :bigint, on_update: :update_all, on_delete: :delete_all),
        null: false
      )
      add(:token, :text, null: false)

      timestamps(updated_at: false)
    end
    create(unique_index("accounts_email_confirmation_tokens", :user_id))
  end
end
