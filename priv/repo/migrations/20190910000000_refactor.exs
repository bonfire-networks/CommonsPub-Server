# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Repo.Migrations.BigRefactor do
  use Ecto.Migration
  alias Ecto.Adapters.SQL

  @meta_tables ~w(mn_peer mn_actor mn_user mn_community mn_collection mn_resource mn_comment mn_like mn_flag)
  @revised [
    {"mn_actor", "actor_id"},
    {"mn_resource", "resource_id"},
    {"mn_comment", "comment_id"},
  ]

  def up do

    ### localisation system

    # countries
    # only updated during migrations!
    create table(:mn_country, primary_key: false) do
      add :id, :char, size: 2, null: false, primary_key: true
      add :english_name, :text, null: false
      add :local_name, :text, null: false
      add :inserted_at, :timestamptz, default: fragment("(now() at time zone 'UTC')")
    end

    # languages
    # only updated during migrations!    
    create table(:mn_language, primary_key: false) do
      add :id, :char, size: 2, null: false, primary_key: true
      add :english_name, :text, null: false
      add :local_name, :text, null: false
      add :inserted_at, :timestamptz, default: fragment("(now() at time zone 'UTC')")
    end

    # whitelists

    create table(:mn_whitelist_register_email_domain) do
      add :domain, :text, null: false
    end

    create unique_index(:mn_whitelist_register_email_domain, :domain)

    create table(:mn_whitelist_register_email) do
      add :email, :text, null: false
    end

    create unique_index(:mn_whitelist_register_email, :email)

    ### meta system

    # database tables participating in the 'meta' abstraction
    # only updated during migrations!
    create table(:mn_meta_table, primary_key: false) do
      add :id, :smallserial, primary_key: true
      add :table, :text, null: false
      add :inserted_at, :timestamptz, default: fragment("(now() at time zone 'UTC')")
    end

    create unique_index(:mn_meta_table, :table)

    # a pointer to an entry in any table participating in the meta abstraction
    create table(:mn_meta_pointer) do
      add :table_id, references("mn_meta_table", type: :int2, on_delete: :restrict), null: false
    end

    create index(:mn_meta_pointer, :table_id)
    
    ### activitypub system
    
    # an activitypub-compatible peer instance
    create table(:mn_peer, primary_key: false) do
      add :id, references("mn_meta_pointer", on_delete: :delete_all), primary_key: true
      add :ap_url_base, :text, null: false
      add :deleted_at, :timestamptz
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:mn_peer, :ap_url_base, where: "deleted_at is null")

    ### actor system
    
    # an actor is either a user or a group actor. it has several
    # defining qualities:
    #  * it authors and owns content
    #  * it has an instance-unique preferred username
    create table(:mn_actor, primary_key: false) do
      add :id, references("mn_meta_pointer", on_delete: :delete_all), primary_key: true
      add :alias_id, references("mn_meta_pointer", on_delete: :delete_all) # user or collection etc.
      add :peer_id, references("mn_peer", on_delete: :delete_all) # null for local
      add :preferred_username, :text # null just in case, expected to be filled
      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      timestamps(type: :utc_datetime_usec)
    end

    create index(:mn_actor, :peer_id, where: "deleted_at is null")
    create unique_index(:mn_actor, :alias_id,  where: "deleted_at is null")
    create unique_index(:mn_actor, [:preferred_username, :peer_id], where: "deleted_at is null")

    # most content of the actor is revision-tracked
    create table(:mn_actor_revision) do
      add :actor_id, references("mn_actor", on_delete: :delete_all), null: false
      add :name, :text
      add :summary, :text
      add :icon, :text
      add :image, :text
      add :extra, :jsonb
      timestamps(updated_at: false, type: :utc_datetime_usec)
    end

    create index(:mn_actor_revision, [:actor_id, :inserted_at])


    ### user system

    # a user that signed up on our instance
    create table(:mn_user, primary_key: false) do
      add :id, references("mn_meta_pointer", on_delete: :delete_all), primary_key: true
      add :email, :text, null: false
      add :password_hash, :text, null: false
      add :confirmed_at, :timestamptz
      add :wants_email_digest, :boolean, null: false, default: false
      add :wants_notifications, :boolean, null: false, default: false
      add :is_local_admin, :boolean, null: false, default: false
      add :deleted_at, :timestamptz
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:mn_user, :email, where: "deleted_at is null")
    
    # a storage for time-limited email confirmation tokens
    create table(:mn_user_email_confirm_token) do
      add :user_id, references("mn_user", on_delete: :delete_all), null: false
      add :expires_at, :timestamptz, null: false
      add :confirmed_at, :timestamptz
      timestamps(type: :utc_datetime_usec)
    end

    create index(:mn_user_email_confirm_token, :user_id, where: "confirmed_at is null")
    
    # a community is a group actor that is home to collections,
    # threads and members
    create table(:mn_community, primary_key: false) do
      add :id, references("mn_meta_pointer", on_delete: :delete_all), primary_key: true
      add :creator_id, references("mn_actor", on_delete: :nilify_all)
      add :primary_language_id, references("mn_language", type: :char, on_delete: :nilify_all)
      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      timestamps(type: :utc_datetime_usec)
    end

    create index(:mn_community, :creator_id, where: "deleted_at is null")
    create index(:mn_community, :primary_language_id, where: "deleted_at is null")

    # a collection is a group actor that is home to resources
    create table(:mn_collection, primary_key: false) do
      add :id, references("mn_meta_pointer", on_delete: :delete_all), primary_key: true
      add :creator_id, references("mn_actor", on_delete: :nilify_all)
      add :primary_language_id, references("mn_language", type: :char, on_delete: :nilify_all)
      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      timestamps(type: :utc_datetime_usec)
    end

    create index(:mn_collection, :creator_id, where: "deleted_at is null")
    create index(:mn_collection, :primary_language_id, where: "deleted_at is null")

    # a resource is an item in a collection, a link somewhere or some text
    create table(:mn_resource, primary_key: false) do
      add :id, references("mn_meta_pointer", on_delete: :delete_all), primary_key: true
      add :creator_id, references("mn_actor", on_delete: :nilify_all)
      add :collection_id, references("mn_collection", on_delete: :delete_all), null: false
      add :primary_language_id, references("mn_language", type: :char, on_delete: :nilify_all)
      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      timestamps(type: :utc_datetime_usec)
    end

    create index(:mn_resource, :creator_id, where: "deleted_at is null")
    create index(:mn_resource, :collection_id, where: "deleted_at is null")
    create index(:mn_resource, :primary_language_id, where: "deleted_at is null")

    create table(:mn_resource_revision) do
      add :resource_id, references("mn_resource", on_delete: :delete_all), null: false
      add :content, :text
      add :url, :string
      add :same_as, :string
      add :free_access, :boolean
      add :public_access, :boolean
      add :license, :string
      add :learning_resource_type, :string
      add :educational_use, {:array, :string}
      add :time_required, :integer
      add :typical_age_range, :string
      timestamps(updated_at: false, type: :utc_datetime_usec)
    end

    create index(:mn_resource_revision, [:resource_id, "inserted_at desc"])

    create table(:mn_thread) do
      add :parent_id, references("mn_meta_pointer", on_delete: :delete_all), null: false
      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      timestamps(type: :utc_datetime_usec)
    end

    create index(:mn_thread, :parent_id, where: "deleted_at is null")

    create table(:mn_comment, primary_key: false) do
      add :id, references("mn_meta_pointer", on_delete: :delete_all), primary_key: true
      add :thread_id, references("mn_thread", on_delete: :delete_all), null: false
      add :reply_to_id, references("mn_comment", on_delete: :nilify_all)
      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      timestamps(type: :utc_datetime_usec)
    end

    create index(:mn_comment, :thread_id, where: "deleted_at is null")

    create table(:mn_comment_revision) do
      add :comment_id, references("mn_comment", on_delete: :delete_all), null: false
      add :content, :text
      timestamps(updated_at: false, type: :utc_datetime_usec)
    end

    create index(:mn_comment_revision, [:comment_id, :inserted_at])

    create table(:mn_follow) do
      add :follower_id, references("mn_actor", on_delete: :delete_all), null: false
      add :followed_id, references("mn_meta_pointer", on_delete: :delete_all), null: false
      add :muted_at, :boolean, null: false
      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:mn_follow,[:follower_id, :followed_id], where: "deleted_at is null")
    create index(:mn_follow, :followed_id, where: "deleted_at is null")

    create table(:mn_like) do
      add :liker_id, references("mn_actor", on_delete: :delete_all), null: false
      add :liked_id, references("mn_meta_pointer", on_delete: :delete_all), null: false
      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:mn_like, [:liker_id, :liked_id], where: "deleted_at is null")

    # a flagged piece of content. may be a user, community,
    # collection, resource, thread, comment
    create table(:mn_flag, primary_key: false) do
      add :id, references("mn_meta_pointer", on_delete: :delete_all), primary_key: true
      add :flagger_id, references("mn_actor", on_delete: :delete_all), null: false
      add :flagged_id, references("mn_meta_pointer", on_delete: :delete_all), null: false
      add :community_id, references("mn_community", on_delete: :nilify_all)
      add :resolver_id, references("mn_actor", on_delete: :nilify_all)
      add :message, :text, null: false
      add :resolved_at, :timestamptz
      timestamps(type: :utc_datetime_usec)
    end

    create index(:mn_flag, :flagger_id)
    create index(:mn_flag, :flagged_id)

    ### blocking system

    # desc: one thing missing is silence/block/ban of user/group/instance,
    #       by users, community moderators, or admins
    
    create table(:mn_block) do
      add :blocker_id, references("mn_actor", on_delete: :delete_all), null: false
      add :blocked_id, references("mn_meta_pointer", on_delete: :delete_all), null: false
      add :published_at, :timestamptz
      add :muted_at, :timestamptz
      add :blocked_at, :timestamptz
      add :deleted_at, :timestamptz
      timestamps(type: :utc_datetime_usec)
    end

    create index(:mn_block, :blocked_id, where: "deleted_at is null")
    create unique_index(:mn_block, [:blocker_id, :blocked_id], where: "deleted_at is null")
    # 

    create table(:mn_worker_task) do
      add :deleted_at, :timestamptz
      add :type, :varchar
      add :data, :jsonb
      timestamps(type: :utc_datetime_usec)
    end

    create index(:mn_worker_task, :updated_at, where: "deleted_at is null")

    create table(:mn_worker_performance) do
      add :task_id, references("mn_worker_task", on_delete: :delete_all)
      timestamps(updated_at: false, type: :utc_datetime_usec)
    end

    create table(:mn_actor_feed, primary_key: false) do
      add :actor_id, references("mn_actor", on_delete: :delete_all), primary_key: true
      add :pointer_id, references("mn_meta_pointer", on_delete: :delete_all), primary_key: true
      timestamps(updated_at: false, type: :utc_datetime_usec)
    end

    create index(:mn_actor_feed, :actor_id)
    create index(:mn_actor_feed, :pointer_id)
    create index(:mn_actor_feed, :inserted_at)

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
      timestamps(type: :utc_datetime_usec)
    end

    # now we are going to do things with what we've already created.
    # ecto naturally wants to delay running any of this because we
    # might be running in mysql which doesn't have DDL transactions
    # as we happen to know we're not, carry on...
    flush()

    # insert records of the tables participating in the meta abstraction
    vals =
      @meta_tables
      |> Enum.map(fn x -> "('#{x}')" end)
      |> Enum.join(", ")
    :ok = execute "insert into mn_meta_table ("table") values #{vals}"

    # create a view showing the latest performance of tasks by workers
    :ok = execute """
    create view mn_worker_performance_latest as
    (select
       distinct on (task_id)
       task_id, id
     from mn_worker_performance
     order by task_id, id
    )
    """
  end

  def down do
  end
end
