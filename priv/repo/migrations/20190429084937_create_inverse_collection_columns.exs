defmodule MoodleNet.Repo.Migrations.CreateInverseCollectionColumns do
  use ActivityPub.Migration

  def change do
    alter table(:activity_pub_objects) do
      add_foreign_key(:collections_id, "activity_pub_collection_aspects", column: :local_id)
      add_foreign_key(:subcommunities_id, "activity_pub_collection_aspects", column: :local_id)
      add_foreign_key(:resources_id, "activity_pub_collection_aspects", column: :local_id)
      add_foreign_key(:subcollections_id, "activity_pub_collection_aspects", column: :local_id)
    end
  end
end
