# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Repo.Migrations.Liking do
  use ActivityPub.Migration

  def change do

    create table(:mn_collection_likes) do
      add_foreign_key(:liked_object_id, "activity_pub_objects")
      add_foreign_key(:liking_object_id, "activity_pub_objects")
      add(:deleted_at, :utc_datetime_usec)
      timestamps()
    end

    create index(:mn_collection_likes, [:liked_object_id])
    create index(:mn_collection_likes, [:liking_object_id])

    create table(:mn_resource_likes) do
      add_foreign_key(:liked_object_id, "activity_pub_objects")
      add_foreign_key(:liking_object_id, "activity_pub_objects")
      add(:deleted_at, :utc_datetime_usec)
      timestamps()
    end

    create index(:mn_resource_likes, [:liked_object_id])
    create index(:mn_resource_likes, [:liking_object_id])

    create table(:mn_comment_likes) do
      add_foreign_key(:liked_object_id, "activity_pub_objects")
      add_foreign_key(:liking_object_id, "activity_pub_objects")
      add(:deleted_at, :utc_datetime_usec)
      timestamps()
    end

    create index(:mn_comment_likes, [:liked_object_id])
    create index(:mn_comment_likes, [:liking_object_id])

     create table(:mn_community_likes) do
      add_foreign_key(:liked_object_id, "activity_pub_objects")
      add_foreign_key(:liking_object_id, "activity_pub_objects")
      add(:deleted_at, :utc_datetime_usec)
      timestamps()
    end

    create index(:mn_community_likes, [:liked_object_id])
    create index(:mn_community_likes, [:liking_object_id])

    create table(:mn_user_likes) do
      add_foreign_key(:liked_object_id, "activity_pub_objects")
      add_foreign_key(:liking_object_id, "activity_pub_objects")
      add(:deleted_at, :utc_datetime_usec)
      timestamps()
    end

    create index(:mn_user_likes, [:liked_object_id])
    create index(:mn_user_likes, [:liking_object_id])

 end

end
