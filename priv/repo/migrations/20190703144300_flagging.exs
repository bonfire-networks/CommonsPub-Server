# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Repo.Migrations.Flagging do
  use ActivityPub.Migration

  def change do

    create table(:activity_pub_object_flags) do
      add_foreign_key(:subject_id, "activity_pub_objects")
      add_foreign_key(:target_id, "activity_pub_objects")
      add(:message, :text, null: false)
    end

    alter table(:activity_pub_objects, primary_key: false) do
      add(:flags_count, :integer, default: 0, null: false)
    end

    create(unique_index(:activity_pub_object_flags, [:subject_id, :target_id], name: :activity_pub_flags_unique_index))

    create_counter_trigger(
      :flags_count,
      :activity_pub_objects,
      :local_id,
      :activity_pub_object_flags,
      :subject_id
    )

    alter table(:activity_pub_actor_aspects, primary_key: false) do
      add_foreign_key(:flags_id, "activity_pub_objects", column: :local_id)
      add(:flags_count, :integer, default: 0, null: false)
    end

    create_counter_trigger(
      :flags_count,
      :activity_pub_actor_aspects,
      :local_id,
      :activity_pub_follows,
      :target_id
    )

  end
end
