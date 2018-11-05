defmodule MoodleNet.Repo.Migrations.CreateActivityPubTables do
  use Ecto.Migration

  def change do
    create table(:activity_pub_objects) do
      add :uri, :text
      add :data, :jsonb, null: false
      add :like_count, :integer, default: 0, null: false
      add :share_count, :integer, default: 0, null: false

      timestamps()
    end

    create table(:activity_pub_actors) do
      add :uri, :text, null: false
      add :nickname, :citext
      add :local, :boolean, null: false
      add :bio, :text
      add :avatar, :jsonb
      add :info, :jsonb, default: "{}"
      add :type, {:array, :text}, default: [], null: false
      add :openness, :text
      add :follower_address, :text, null: false
      add :follower_count, :integer, null: false, default: 0

      timestamps()
    end

    create table(:activity_pub_activities) do
      add :uri, :text, null: false
      add :data, :jsonb, null: false
      add :local, :boolean, null: false
      add :actor_id, references("activity_pub_actors", on_delete: :delete_all, on_update: :update_all), null: false
      add :object_id, references("activity_pub_objects", on_delete: :delete_all, on_update: :update_all), null: false
      add :recipient_actor_uris, {:array, :bigint}, default: [], null: false

      timestamps()
    end

    create table(:activity_pub_actors_relations) do
      add :subject_actor_id, references("activity_pub_actors", on_delete: :delete_all, on_update: :update_all), null: false
      add :target_actor_id, references("activity_pub_actors", on_delete: :delete_all, on_update: :update_all), null: false
      add :type, {:array, :text}, default: [], null: false
      add :confirmed, :boolean, null: false

      timestamps()
    end
  end
end
