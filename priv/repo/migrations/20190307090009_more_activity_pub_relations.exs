defmodule MoodleNet.Repo.Migrations.MoreActivityPubRelations do
  use ActivityPub.Migration

  def change do
    create table(:activity_pub_object_previews) do
      add_foreign_key(:subject_id, "activity_pub_objects")
      add_foreign_key(:target_id, "activity_pub_objects")
    end

    create table(:activity_pub_object_generators) do
      add_foreign_key(:subject_id, "activity_pub_objects")
      add_foreign_key(:target_id, "activity_pub_objects")
    end

    create table(:activity_pub_object_attachments) do
      add_foreign_key(:subject_id, "activity_pub_objects")
      add_foreign_key(:target_id, "activity_pub_objects")
    end

    rename table(:activity_pub_activity_origins), :activity_id, to: :subject_id
  end
end
