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
      add(:reason, :string, null: false)
      add(:open, :boolean, null: false, default: true)
    end

    create(unique_index(:mn_collection_flags, [:flagged_object_id, :flagging_object_id], name: :mn_collection_flags_once_index))

    create table(:mn_resource_flags) do
      add_foreign_key(:flagged_object_id, "activity_pub_objects")
      add_foreign_key(:flagging_object_id, "activity_pub_objects")
      add(:reason, :string, null: false)
      add(:open, :boolean, null: false, default: true)
    end

    create(unique_index(:mn_resource_flags, [:flagged_object_id, :flagging_object_id], name: :mn_resource_flags_once_index))

    create table(:mn_comment_flags) do
      add_foreign_key(:flagged_object_id, "activity_pub_objects")
      add_foreign_key(:flagging_object_id, "activity_pub_objects")
      add(:reason, :string, null: false)
      add(:open, :boolean, null: false, default: true)
    end

    create(unique_index(:mn_comment_flags, [:flagged_object_id, :flagging_object_id], name: :mn_comment_flags_once_index))

  end

end
