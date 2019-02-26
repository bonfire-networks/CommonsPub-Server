defmodule MoodleNet.Repo.Migrations.AddMoreFieldsToActivities do
  use ActivityPub.Migration

  def change do
    alter table(:activity_pub_activity_aspects) do
      add(:_public, :boolean, null: false, default: true)
    end

    create table(:activity_pub_activity_targets) do
      add_foreign_key(:subject_id, "activity_pub_activity_aspects")
      add_foreign_key(:target_id, "activity_pub_objects")
    end

    create table(:activity_pub_activity_results) do
      add_foreign_key(:subject_id, "activity_pub_activity_aspects")
      add_foreign_key(:target_id, "activity_pub_objects")
    end

    create table(:activity_pub_activity_instruments) do
      add_foreign_key(:subject_id, "activity_pub_activity_aspects")
      add_foreign_key(:target_id, "activity_pub_objects")
    end

  end
end
