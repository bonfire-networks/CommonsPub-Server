# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Repo.Migrations.BigRefactor do
  use ActivityPub.Migration

  @meta_tables ~w(mn_actor mn_resource mn_comment mn_flag)a
  def up do

    ### localisation system

    # countries
    # only updated during migrations!
    @primary_key false
    create table(:mn_country) do
      add :iso2, :text, size: 2, null: false, primary_key: true
      add :english_name, :text, null: false
      add :local_name, :text, null: false
      timestamps()
    end

    # languages
    # only updated during migrations!    
    @primary_key false
    create table(:mn_language) do
      add :iso2, :text, size: 2, null: false, primary_key: true
      add :english_name, :text, null: false
      add :local_name, :text, null: false
      timestamps()
    end

    create unique_index(:mn_language, :iso2)

    ### meta system

    # database tables participating in the 'meta' abstraction
    # only updated during migrations!
    @primary_key false
    create table(:mn_meta_table) do
      add :id, :int2, primary_key: true
      add :table, :text, null: false
      timestamps()
    end

    create unique_index(:mn_meta_table, :table)

    # a pointer to an entry in any table participating in the meta abstraction
    create table(:mn_meta_pointer) do
      add :table_id, references("mn_meta_table"), null: false
    end

    create index(:mn_meta_pointer, :table_id)
    
    ### activitypub system
    
    # an activitypub-compatible peer instance
    create table(:mn_peer) do
      add :ap_url_base, :text, null: false
      field :deleted, :boolean, null: false
      timestamps()
    end

    create unique_index(:mn_peer, :ap_url_base)

    ### actor system
    
    # an actor is either a user or a group actor. it has several
    # defining qualities:
    #  * it authors and owns content
    #  * it has an instance-unique preferred username
    @primary_key false
    create table(:mn_actor) do
      add :id, references("mn_pointer"), primary_key: true
      add :peer_id, references("mn_peer") # null for local
      add :preferred_username, :text
      add :is_public, :boolean, null: false
      add :deleted, :boolean, null: false
      timestamps()
    end

    create index(:mn_actor, :peer_id)
    create index(:mn_actor, :preferred_username)
    create unique_index(:mn_actor, [:peer_id, :preferred_username])

    create table(:mn_actor_revision) do
      add :actor_id, references("mn_actor"), null: false
      add :name, :text
      add :summary, :text
      add :icon, :text
      add :image, :text
      add :extra, :jsonb
      timestamps(updated_at: false)
    end

    create index(:mn_actor_revision, :actor_id)
    create index(:mn_actor_revision, [:actor_id, :inserted_at])

    ### user system

    # a user that signed up on our instance
    create table(:mn_local_user) do
      add :actor_id, references("mn_actor"), null: false
      add :email, :text, null: false
      add :password_hash, :text, null: false
      add :confirmed_at, :utc_datetime_usec
      add :wants_digest, :boolean, null: false
      add :wants_notifications, :boolean, null: false
      add :deleted, :boolean, null: false
      timestamps()
    end

    create unique_index(:mn_local_user, :actor_id)
    create unique_index(:mn_local_user, :email)
    
    # a user signed up on another instance
    create table(:mn_remote_user) do
      add :actor_id, references("mn_actor"), null: false
      add :wants_notifications, :boolean, null: false
      add :deleted, :boolean, null: false
      timestamps()
    end

    create unique_index(:mn_remote_user, :actor_id)
    
    # a storage for time-limited email confirmation tokens
    create table(:mn_local_user_email_token) do
      add :local_user_id, references("mn_local_user"), null: false
      add :expires_at, :utc_datetime_usec, null: false
      add :confirmed_at, :utc_datetime_usec
      timestamps()
    end

    # a community is a group actor that is home to collections,
    # threads and members
    create table(:mn_community) do
      add :actor_id, references("mn_actor"), null: false
      add :primary_language, references("mn_language"), null: false
      add :creator_id, references("mn_actor"), null: false
      add :is_public, :boolean, null: false
      add :is_deleted, :boolean, null: false
      timestamps()
    end

    # a collection is a group actor that is home to resources
    @primary_key false
    create table(:mn_collection) do
      add :actor_id, references("mn_actor"), null: false
      add :primary_language, references("mn_language"), null: false
      add :creator_id, references("mn_actor"), null: false
      add :is_public, :boolean, null: false
      add :is_deleted, :boolean, null: false
      timestamps()
    end

    # a resource is an item in a collection, a link somewhere
    @primary_key false
    create table(:mn_resource) do
      add :id, references("mn_pointer"), primary_key: true
      add :collection_id, references("mn_collection"), null: false
      add :is_public, :boolean, null: false
      add :is_deleted, :boolean, null: false
      timestamps()
    end

    create table(:mn_thread) do
      add :parent_id, references("mn_pointer"), null: false
      add :is_public, :boolean, null: false
      add :is_deleted, :boolean, null: false
      timestamps()
    end

    @primary_key false
    create table(:mn_comment) do
      add :id, references("mn_pointer"), primary_key: true
      add :thread_id, references("mn_thread")
      add :reply_to_id, references("mn_comment")
      add :is_public, :boolean, null: false
      add :is_deleted, :boolean, null: false
      timestamps()
    end

    create index(:mn_comment, :thread_id)

    create table(:mn_follow) do
      add :follower_id, references("mn_actor"), null: false
      add :followed_id, references("mn_actor"), null: false
      add :is_muted, :boolean, null: false
      add :is_public, :boolean, null: false
      timestamps()
    end

    create table(:mn_like) do
      add :liker_id, references("mn_actor"), null: false
      add :liked_id, references("mn_pointer"), null: false
      add :is_public, :boolean
      timestamps()
    end

    # a flagged piece of content. may be a user, community,
    # collection, resource, thread, comment
    create table(:mn_flag) do
      add :flagger_id, references("mn_actor"), null: false
      add :flagged_id, references("mn_pointer"), null: false
      add :community_id, references("mn_community")
      add :resolver_id, references("mn_actor")
      add :message, :text, null: false
      add :resolved_at, :utc_datetime_usec
      timestamps()
    end

    create table(:mn_) do
      timestamps()
    end
    create table(:mn_) do
      timestamps()
    end

    # one thing missing is silence/block/ban of user/group/instance, by users, community moderators, or admins

    ## membership, likes, follows, flags

    create table(:mn_worker_publish) do
      add :pointer_id, references("mn_pointer"), null: false
      add :started_at, :utc_datetime_usec
      add :completed_at, :utc_datetime_usec
      timestamps()
    end

    create table(:mn_actor_feed) do
      add :actor_id, references("mn_actor"), null: false
      add :pointer_id, references("mn_pointer"), null: false
      timestamps(updated_at: false)
    end

    create table(:mn_community_role) do
      add :name, :text, null: false
      # administration
      add :can_grant_role, :boolean, null: false
      add :can_revoke_role, :boolean, null: false
      # moderation
      add :can_list_flag, :boolean, null: false
      add :can_resolve_flag, :boolean, null: false
      add :can_ban, :boolean, null: false
      # community
      add :can_edit_community, :boolean, null: false
      # collections
      add :can_create_collection, :boolean, null: false
      add :can_edit_collection, :boolean, null: false
      add :can_delete_collection, :boolean, null: false
      # resources
      add :can_create_resource, :boolean, null: false
      add :can_edit_resource, :boolean, null: false
      add :can_delete_resource, :boolean, null: false
      # comments / threads
      add :can_edit_comment, :boolean, null: false
      add :can_delete_comment, :boolean, null: false
      timestamps()
    end

    Repo.insert_all
  end

  def down do
  end
end
