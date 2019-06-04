# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Repo.Migrations.CreateInverseCollectionColumns do
  use ActivityPub.Migration

  def change do
    alter table(:activity_pub_objects) do
      add(
        :collections_id,
        references("activity_pub_collection_aspects",
          type: :bigint,
          on_update: :update_all,
          on_delete: :nilify_all,
          column: :local_id
        )
      )

      add(
        :subcommunities_id,
        references("activity_pub_collection_aspects",
          type: :bigint,
          on_update: :update_all,
          on_delete: :nilify_all,
          column: :local_id
        )
      )

      add(
        :resources_id,
        references("activity_pub_collection_aspects",
          type: :bigint,
          on_update: :update_all,
          on_delete: :nilify_all,
          column: :local_id
        )
      )

      add(
        :subcollections_id,
        references("activity_pub_collection_aspects",
          type: :bigint,
          on_update: :update_all,
          on_delete: :nilify_all,
          column: :local_id
        )
      )

      add(
        :threads_id,
        references("activity_pub_collection_aspects",
          type: :bigint,
          on_update: :update_all,
          on_delete: :nilify_all,
          column: :local_id
        )
      )
    end
  end
end
