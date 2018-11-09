defmodule MoodleNet.Repo.Migrations.CreateActivityPubTables do
  use ActivityPub.Migration

  def change do
    create table(:activity_pub_objects) do
      add(:uri, :text)
      add(:data, :jsonb, null: false)
      add(:like_count, :integer, default: 0, null: false)
      add(:share_count, :integer, default: 0, null: false)

      timestamps()
    end

    create table(:activity_pub_actors) do
      add(:type, {:array, :text}, default: [], null: false)
      add(:uri, :text)
      add(:name, :text)
      add(:summary, :text)
      add(:preferred_username, :citext)
      add(:avatar, :jsonb)
      add(:info, :jsonb, default: "{}")

      add(:local, :boolean, null: false)
      add(:openness, :text)

      add(:inbox_uri, :string)
      add(:outbox_uri, :string)
      add(:following_uri, :string)
      add(:followers_uri, :string)
      add(:liked_uri, :string)
      add(:streams, :jsonb, default: "{}")
      add(:shared_inbox_uri, :string)
      add(:proxy_url, :string)

      add(:followers_count, :integer, null: false, default: 0)
      add(:following_count, :integer, null: false, default: 0)

      timestamps()
    end

    create table(:activity_pub_activities) do
      add(:uri, :text, null: false)
      add(:data, :jsonb, null: false)
      add(:local, :boolean, null: false)

      add_foreign_key(:actor_id, "activity_pub_actors")
      add_foreign_key(:object_id, "activity_pub_objects")

      add(:recipient_actor_uris, {:array, :bigint}, default: [], null: false)

      timestamps()
    end

    create table(:activity_pub_actors_relations) do
      add_foreign_key(:subject_actor_id, "activity_pub_actors")
      add_foreign_key(:target_actor_id, "activity_pub_actors")
      add(:type, {:array, :text}, default: [], null: false)
      add(:confirmed, :boolean, null: false)

      timestamps()
    end

    create table(:activity_pub_follows) do
      add_foreign_key(:follower_id, "activity_pub_actors")
      add_foreign_key(:following_id, "activity_pub_actors")

      timestamps(updated_at: false)
    end

    create(unique_index(:activity_pub_follows, [:follower_id, :following_id]))

    # create_counter_trigger(
    #   :followers_count,
    #   :activity_pub_actors,
    #   :id,
    #   :activity_pub_follows,
    #   :following_id
    # )

    # create_counter_trigger(
    #   :followings_count,
    #   :activity_pub_actors,
    #   :id,
    #   :activity_pub_follows,
    #   :follower_id
    # )
  end
end
