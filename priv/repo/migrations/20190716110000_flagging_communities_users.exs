# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Repo.Migrations.FlaggingCommunitiesUsers do
  use ActivityPub.Migration

  def change do

    create table(:mn_community_flags) do
      add_foreign_key(:flagged_object_id, "activity_pub_objects")
      add_foreign_key(:flagging_object_id, "activity_pub_objects")
      add(:reason, :string, null: false)
      add(:open, :boolean, null: false, default: true)
    end

    create(unique_index(:mn_community_flags, [:flagged_object_id, :flagging_object_id], name: :mn_community_flags_once_index))

    create table(:mn_user_flags) do
      add_foreign_key(:flagged_object_id, "activity_pub_objects")
      add_foreign_key(:flagging_object_id, "activity_pub_objects")
      add(:reason, :string, null: false)
      add(:open, :boolean, null: false, default: true)
    end

    create(unique_index(:mn_user_flags, [:flagged_object_id, :flagging_object_id], name: :mn_user_flags_once_index))

  end

end
