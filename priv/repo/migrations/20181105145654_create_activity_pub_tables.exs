defmodule MoodleNet.Repo.Migrations.CreateActivityPubTables do
  use ActivityPub.Migration

  def change do
    create table(:activity_pub_objects, primary_key: false) do
      add(:local_id, :bigserial, primary_key: true)
      add(:"@context", :json)
      add(:id, :text)
      add(:type, {:array, :text})
      add(:local, :boolean, null: false)

      add(:content, :jsonb)
      add(:name, :jsonb)
      add(:end_time, :utc_datetime)
      add(:published, :utc_datetime)
      add(:start_time, :utc_datetime)
      add(:summary, :jsonb)
      add(:updated, :utc_datetime)
      add(:to, {:array, :text})
      add(:bto, {:array, :text})
      add(:cc, {:array, :text})
      add(:bcc, {:array, :text})
      add(:media_type, :text)
      add(:duration, :text)

      add(:extension_fields, :map)

      add(:like_count, :integer, default: 0, null: false)
      add(:share_count, :integer, default: 0, null: false)

      timestamps()
    end

    create(unique_index(:activity_pub_objects, :id, where: "id IS NOT NULL"))
    create(index(:activity_pub_objects, :type))

    create table(:activity_pub_actor_aspects, primary_key: false) do
      add_foreign_key(:local_id, "activity_pub_objects", primary_key: true, null: false)
      add(:inbox, :text)
      add(:outbox, :text)
      add(:following, :text)
      add(:followers, :text)
      add(:liked, :text)
      add(:preferred_username, :text)
      add(:streams, :jsonb)
      add(:endpoints, :jsonb)

      timestamps()
    end
    create(unique_index(:activity_pub_actor_aspects, :local_id))

    create table(:activity_pub_activity_aspects, primary_key: false) do
      add_foreign_key(:local_id, "activity_pub_objects", primary_key: true, null: false, column: :local_id)
    end
    create(unique_index(:activity_pub_activity_aspects, :local_id))

    create table(:activity_pub_collection_aspects, primary_key: false) do
      add_foreign_key(:local_id, "activity_pub_objects", primary_key: true, null: false, column: :local_id)
      add(:total_items, :integer, default: 0)
    end
    create(unique_index(:activity_pub_collection_aspects, :local_id))

    create table(:activity_pub_activity_objects) do
      add_foreign_key(:activity_id, "activity_pub_activity_aspects")
      add_foreign_key(:object_id, "activity_pub_objects")

      timestamps(updated_at: false)
    end

    create table(:activity_pub_activity_actors) do
      add_foreign_key(:activity_id, "activity_pub_activity_aspects")
      add_foreign_key(:object_id, "activity_pub_actor_aspects")

      timestamps(updated_at: false)
    end

    create table(:activity_pub_attributed_tos) do
      add_foreign_key(:subject_id, "activity_pub_objects")
      add_foreign_key(:object_id, "activity_pub_objects")
    end

    # create table(:activity_pub_activity_origins) do
    #   add_foreign_key(:activity_id, "activity_pub_activity_aspects", column: :local_id)
    #   add_foreign_key(:object_id, "activity_pub_objects", column: :local_id)

    #   timestamps(updated_at: false)
    # end

    create table(:activity_pub_follows) do
      add_foreign_key(:follower_id, "activity_pub_actor_aspects")
      add_foreign_key(:following_id, "activity_pub_actor_aspects")

      timestamps(updated_at: false)
    end

    create(unique_index(:activity_pub_follows, [:follower_id, :following_id], name: :activity_pub_follows_unique_index))

    create_counter_trigger(
      :followers_count,
      :activity_pub_actor_aspects,
      :local_id,
      :activity_pub_follows,
      :following_id
    )

    create_counter_trigger(
      :following_count,
      :activity_pub_actor_aspects,
      :local_id,
      :activity_pub_follows,
      :follower_id
    )
  end

    # create table(:activity_pub_actors_relations) do
    #   add_foreign_key(:subject_actor_id, "activity_pub_actors")
    #   add_foreign_key(:target_actor_id, "activity_pub_actors")
    #   add(:type, {:array, :text}, default: [], null: false)
    #   add(:confirmed, :boolean, null: false)

    #   timestamps()
    # end
end
