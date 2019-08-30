# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Repo.Migrations.Flagging do
  use ActivityPub.Migration

  def change do

    create table(:mn_collection_flags) do
      add_foreign_key(:flagged_object_id, "activity_pub_objects")
      add_foreign_key(:flagging_object_id, "activity_pub_objects")
      add_foreign_key(:community_object_id, "activity_pub_objects")
      add(:reason, :string, null: false)
      add(:closed_at, :utc_datetime)
      add(:open, :boolean, null: false, default: true)
      timestamps()
    end

    create index(:mn_collection_flags, [:flagged_object_id])
    create index(:mn_collection_flags, [:flagging_object_id])
    create index(:mn_collection_flags, [:community_object_id])
    
    create table(:mn_resource_flags) do
      add_foreign_key(:flagged_object_id, "activity_pub_objects")
      add_foreign_key(:flagging_object_id, "activity_pub_objects")
      add_foreign_key(:community_object_id, "activity_pub_objects")
      add(:reason, :string, null: false)
      add(:closed_at, :utc_datetime)
      add(:open, :boolean, null: false, default: true)
      timestamps()
    end

    create index(:mn_resource_flags, [:flagged_object_id])
    create index(:mn_resource_flags, [:flagging_object_id])
    create index(:mn_resource_flags, [:community_object_id])

    create table(:mn_comment_flags) do
      add_foreign_key(:flagged_object_id, "activity_pub_objects")
      add_foreign_key(:flagging_object_id, "activity_pub_objects")
      add_foreign_key(:community_object_id, "activity_pub_objects")
      add(:reason, :string, null: false)
      add(:closed_at, :utc_datetime)
      add(:open, :boolean, null: false, default: true)
      timestamps()
    end

    create index(:mn_comment_flags, [:flagged_object_id])
    create index(:mn_comment_flags, [:flagging_object_id])
    create index(:mn_comment_flags, [:community_object_id])

     create table(:mn_community_flags) do
      add_foreign_key(:flagged_object_id, "activity_pub_objects")
      add_foreign_key(:flagging_object_id, "activity_pub_objects")
      add(:reason, :string, null: false)
      add(:closed_at, :utc_datetime)
      add(:open, :boolean, null: false, default: true)
      timestamps()
    end

    create index(:mn_community_flags, [:flagged_object_id])
    create index(:mn_community_flags, [:flagging_object_id])

    create table(:mn_user_flags) do
      add_foreign_key(:flagged_object_id, "activity_pub_objects")
      add_foreign_key(:flagging_object_id, "activity_pub_objects")
      add(:reason, :string, null: false)
      add(:closed_at, :utc_datetime)
      add(:open, :boolean, null: false, default: true)
      timestamps()
    end

    create index(:mn_user_flags, [:flagged_object_id])
    create index(:mn_user_flags, [:flagging_object_id])

 end

end
