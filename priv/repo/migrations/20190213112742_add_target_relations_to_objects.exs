defmodule MoodleNet.Repo.Migrations.AddTargetRelationsToObjects do
  use ActivityPub.Migration

  def change do
    create table(:activity_pub_object_tos) do
      add_foreign_key(:subject_id, "activity_pub_objects")
      add_foreign_key(:target_id, "activity_pub_objects")
    end

    create table(:activity_pub_object_btos) do
      add_foreign_key(:subject_id, "activity_pub_objects")
      add_foreign_key(:target_id, "activity_pub_objects")
    end

    create table(:activity_pub_object_ccs) do
      add_foreign_key(:subject_id, "activity_pub_objects")
      add_foreign_key(:target_id, "activity_pub_objects")
    end

    create table(:activity_pub_object_bccs) do
      add_foreign_key(:subject_id, "activity_pub_objects")
      add_foreign_key(:target_id, "activity_pub_objects")
    end

    create table(:activity_pub_object_audiences) do
      add_foreign_key(:subject_id, "activity_pub_objects")
      add_foreign_key(:target_id, "activity_pub_objects")
    end
  end
end
