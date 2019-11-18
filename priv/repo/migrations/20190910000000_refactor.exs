# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Repo.Migrations.BigRefactor do
  use Ecto.Migration
  alias MoodleNet.Repo
  import Ecto.Query

  @meta_tables [] ++
    ~w(mn_country mn_language mn_peer mn_user mn_community mn_collection mn_resource) ++
    ~w(mn_activity mn_thread mn_comment mn_like mn_flag mn_follow mn_block) ++
    ~w(mn_access_register_email mn_access_register_email_domain)

  @languages [
    {"en", "eng", "English", "English"}
  ]
  @tag_categories ["Hashtag", "K-12 Classification"]
    
  @countries [
    {"nl", "nld", "Netherlands", "Nederland"}
  ]
  def up do

    execute """
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp"
    """
    ### localisation system

    ### meta system

    # database tables participating in the 'meta' abstraction
    # only updated during migrations!
    create table(:mn_table) do
      add :table, :text, null: false
      add :created_at, :timestamptz, null: false,
	default: fragment("(now() at time zone 'UTC')")
    end

    create unique_index(:mn_table, :table)

    # a pointer to an entry in any table participating in the meta abstraction
    create table(:mn_pointer) do
      add :table_id, references("mn_table", on_delete: :restrict), null: false
    end

    create index(:mn_pointer, :table_id)

    # countries
    
    create table(:mn_country, primary_key: false) do
      add :id, references("mn_pointer", on_delete: :delete_all), primary_key: true
      add :iso_code2, :string, size: 2
      add :iso_code3, :string, size: 3
      add :english_name, :text, null: false
      add :local_name, :text, null: false
      add :deleted_at, :timestamptz
      add :published_at, :timestamptz
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create unique_index(:mn_country, :iso_code2)
    create unique_index(:mn_country, :iso_code3)

    # languages

    create table(:mn_language, primary_key: false) do
      add :id, references("mn_pointer", on_delete: :delete_all), primary_key: true
      add :iso_code2, :string, size: 2
      add :iso_code3, :string, size: 3
      add :english_name, :text, null: false
      add :local_name, :text, null: false
      add :deleted_at, :timestamptz
      add :published_at, :timestamptz
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create unique_index(:mn_language, :iso_code2)
    create unique_index(:mn_language, :iso_code3)

    # access control

    create table(:mn_access_register_email_domain, primary_key: false) do
      add :id, references("mn_pointer", on_delete: :delete_all), primary_key: true
      add :domain, :text, null: false
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create unique_index(:mn_access_register_email_domain, :domain)

    create table(:mn_access_register_email, primary_key: false) do
      add :id, references("mn_pointer", on_delete: :delete_all), primary_key: true
      add :email, :text, null: false
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create unique_index(:mn_access_register_email, :email)

    ### activitypub system

    # an activitypub-compatible peer instance
    create table(:mn_peer, primary_key: false) do
      add :id, references("mn_pointer", on_delete: :delete_all), primary_key: true
      add :ap_url_base, :text, null: false
      add :deleted_at, :timestamptz
      add :disabled_at, :timestamptz
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create unique_index(:mn_peer, :ap_url_base, where: "deleted_at is null")

    ### actor system

    # basically a reservation table for unique ids plus activitypub stuff
    # currently linked to a user, community or collection
    create table(:mn_actor) do
      add :peer_id, references("mn_peer", on_delete: :delete_all) # null for local
      add :preferred_username, :text, null: false
      add :canonical_url, :text
      add :signing_key, :text
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create unique_index(
      :mn_actor, [:preferred_username, :peer_id],
      name: :mn_actor_preferred_username_peer_id_index
    )
    create unique_index(
      :mn_actor, [:preferred_username],
      where: "peer_id is null",
      name: :mn_actor_peer_id_null_index
    )

    ### user system

    # a user that signed up on our instance

    create table(:mn_local_user) do
      add :email, :text, null: false
      add :password_hash, :text, null: false
      add :confirmed_at, :timestamptz
      add :deleted_at, :timestamptz
      add :wants_email_digest, :boolean, null: false, default: false
      add :wants_notifications, :boolean, null: false, default: false
      add :is_instance_admin, :boolean, null: false, default: false
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create unique_index(:mn_local_user, :email, where: "deleted_at is null")

    # any user, including remote ones

    create table(:mn_user, primary_key: false) do
      add :id, references("mn_pointer", on_delete: :delete_all), primary_key: true
      add :actor_id, references("mn_actor", on_delete: :delete_all)
      add :local_user_id, references("mn_local_user", on_delete: :nilify_all)
      add :primary_language_id, references("mn_language", on_delete: :nilify_all)
      add :name, :text
      add :summary, :text
      add :location, :text
      add :website, :text
      add :icon, :text
      add :image, :text
      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      add :disabled_at, :timestamptz
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create unique_index(:mn_user, :actor_id)
    create unique_index(:mn_user, :local_user_id)
    create unique_index(:mn_user, :primary_language_id)

    # a storage for time-limited email confirmation tokens
    create table(:mn_local_user_email_confirm_token) do
      add :local_user_id, references("mn_local_user", on_delete: :delete_all), null: false
      add :expires_at, :timestamptz, null: false
      add :confirmed_at, :timestamptz
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create index(:mn_local_user_email_confirm_token, :local_user_id)

    create table(:mn_local_user_reset_password_token) do
      add :local_user_id, references("mn_local_user", on_delete: :delete_all), null: false
      add :expires_at, :timestamptz, null: false
      add :reset_at, :timestamptz
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create index(:mn_local_user_reset_password_token, :local_user_id)
    
    # a community is a group actor that is home to collections,
    # threads and members
    create table(:mn_community, primary_key: false) do
      add :id, references("mn_pointer", on_delete: :delete_all), primary_key: true
      add :actor_id, references(:mn_actor, on_delete: :delete_all)
      add :creator_id, references("mn_user", on_delete: :nilify_all)
      add :primary_language_id, references("mn_language", on_delete: :nilify_all)
      add :name, :text
      add :summary, :text
      add :icon, :text
      add :image, :text
      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      add :disabled_at, :timestamptz
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create index(:mn_community, :created_at)
    create index(:mn_community, :updated_at)
    create index(:mn_community, :creator_id)
    create index(:mn_community, :actor_id)
    create index(:mn_community, :primary_language_id)

    # a collection is a group actor that is home to resources
    create table(:mn_collection, primary_key: false) do
      add :id, references("mn_pointer", on_delete: :delete_all), primary_key: true
      add :actor_id, references("mn_actor", on_delete: :delete_all)
      add :creator_id, references("mn_user", on_delete: :nilify_all)
      add :community_id, references("mn_community", on_delete: :nilify_all)
      add :primary_language_id, references("mn_language", on_delete: :nilify_all)
      add :name, :text
      add :summary, :text
      add :icon, :text
      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      add :disabled_at, :timestamptz
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create index(:mn_collection, :created_at)
    create index(:mn_collection, :updated_at)
    create index(:mn_collection, :actor_id)
    create index(:mn_collection, :creator_id)
    create index(:mn_collection, :community_id)
    create index(:mn_collection, :primary_language_id)

    # a resource is an item in a collection, a link somewhere or some text
    create table(:mn_resource, primary_key: false) do
      add :id, references("mn_pointer", on_delete: :delete_all), primary_key: true
      add :canonical_url, :text
      add :creator_id, references("mn_user", on_delete: :nilify_all)
      add :collection_id, references("mn_collection", on_delete: :nilify_all)
      add :primary_language_id, references("mn_language", on_delete: :nilify_all)
      add :name, :string
      add :summary, :text
      add :url, :string
      add :license, :string
      add :icon, :string
      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      add :disabled_at, :timestamptz
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create index(:mn_resource, :created_at)
    create index(:mn_resource, :updated_at)
    create unique_index(:mn_resource, :canonical_url)
    create index(:mn_resource, :creator_id)
    create index(:mn_resource, :collection_id)
    create index(:mn_resource, :primary_language_id)

    ### comment system

    create table(:mn_thread, primary_key: false) do
      add :id, references("mn_pointer", on_delete: :delete_all), primary_key: true
      add :canonical_url, :text
      add :creator_id, references("mn_user", on_delete: :nilify_all)
      add :context_id, references("mn_pointer", on_delete: :nilify_all)
      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      add :locked_at, :timestamptz
      add :hidden_at, :timestamptz
      add :is_local, :boolean, null: false
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create index(:mn_thread, :created_at)
    create index(:mn_thread, :updated_at)
    create unique_index(:mn_thread, :canonical_url)
    create index(:mn_thread, :creator_id)
    create index(:mn_thread, :context_id)

    create table(:mn_comment, primary_key: false) do
      add :id, references("mn_pointer", on_delete: :delete_all), primary_key: true
      add :canonical_url, :text
      add :creator_id, references("mn_user", on_delete: :nilify_all)
      add :thread_id, references("mn_thread", on_delete: :delete_all), null: false
      add :reply_to_id, references("mn_comment", on_delete: :nilify_all)
      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      add :hidden_at, :timestamptz
      add :content, :text
      add :is_local, :boolean, null: false
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create index(:mn_comment, :created_at)
    create index(:mn_comment, :updated_at)
    create unique_index(:mn_comment, :canonical_url)
    create index(:mn_comment, :creator_id)
    create index(:mn_comment, :thread_id)

    create table(:mn_follow, primary_key: false) do
      add :id, references("mn_pointer", on_delete: :delete_all), primary_key: true
      add :canonical_url, :text
      add :follower_id, references("mn_user", on_delete: :nilify_all)
      add :followed_id, references("mn_pointer", on_delete: :nilify_all)
      add :muted_at, :timestamptz
      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      add :is_local, :boolean, null: false
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end
    
    create index(:mn_follow, :created_at)
    create index(:mn_follow, :updated_at)
    create unique_index(:mn_follow, :canonical_url)
    create unique_index(:mn_follow,[:follower_id, :followed_id], where: "deleted_at is null")
    create index(:mn_follow, :followed_id)

    create table(:mn_like, primary_key: false) do
      add :id, references("mn_pointer", on_delete: :delete_all), primary_key: true
      add :canonical_url, :text
      add :liker_id, references("mn_user", on_delete: :nilify_all)
      add :liked_id, references("mn_pointer", on_delete: :nilify_all)
      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      add :is_local, :boolean, null: false
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create index(:mn_like, :created_at)
    create index(:mn_like, :updated_at)
    create unique_index(:mn_like, :canonical_url)
    create unique_index(:mn_like, [:liker_id, :liked_id], where: "deleted_at is null")
    create index(:mn_like, :liked_id, where: "deleted_at is null")

    # a flagged piece of content. may be a user, community,
    # collection, resource, thread, comment
    create table(:mn_flag, primary_key: false) do
      add :id, references("mn_pointer", on_delete: :delete_all), primary_key: true
      add :canonical_url, :text
      add :flagger_id, references("mn_user", on_delete: :nilify_all)
      add :flagged_id, references("mn_pointer", on_delete: :nilify_all)
      add :community_id, references("mn_community", on_delete: :nilify_all)
      add :message, :text, null: false
      add :resolved_at, :timestamptz
      add :deleted_at, :timestamptz
      add :is_local, :boolean, null: false
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create index(:mn_flag, :created_at)
    create index(:mn_flag, :updated_at)
    create unique_index(:mn_flag, :canonical_url)
    create unique_index(:mn_flag, [:flagger_id, :flagged_id], where: "deleted_at is null")
    create index(:mn_flag, :flagged_id, where: "deleted_at is null")
    create index(:mn_flag, :community_id)

    ### blocking system

    # desc: one thing missing is silence/block/ban of user/group/instance,
    #       by users, community moderators, or admins

    create table(:mn_block, primary_key: false) do
      add :id, references("mn_pointer", on_delete: :delete_all), primary_key: true
      add :canonical_url, :text
      add :blocker_id, references("mn_user", on_delete: :delete_all), null: false
      add :blocked_id, references("mn_pointer", on_delete: :delete_all), null: false
      add :published_at, :timestamptz
      add :muted_at, :timestamptz
      add :blocked_at, :timestamptz
      add :deleted_at, :timestamptz
      add :is_local, :boolean, null: false
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create index(:mn_block, :created_at)
    create index(:mn_block, :updated_at)
    create unique_index(:mn_block, :canonical_url)
    create unique_index(:mn_block, [:blocker_id, :blocked_id], where: "deleted_at is null")
    create index(:mn_block, :blocked_id, where: "deleted_at is null")

    ### tagging

    # create table(:mn_tag_category, primary_key: false) do
    #   add :id, references("mn_pointer", on_delete: :delete_all), primary_key: true
    #   add :canonical_url, :text
    #   add :name, :text
    #   add :published_at, :timestamptz
    #   add :deleted_at, :timestamptz
    #   timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    # end

    # create index(:mn_tag_category, :created_at)
    # create index(:mn_tag_category, :updated_at)
    # create unique_index(:mn_tag_category, :canonical_url)
    # create unique_index(:mn_tag_category, :name, where: "deleted_at is null")

    # create table(:mn_tag, primary_key: false) do
    #   add :id, references("mn_pointer", on_delete: :delete_all), primary_key: true
    #   add :canonical_url, :text
    #   add :name, :text, null: false
    #   add :published_at, :timestamptz
    #   add :deleted_at, :timestamptz
    #   timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    # end

    # create index(:mn_tag, :created_at)
    # create index(:mn_tag, :updated_at)
    # create unique_index(:mn_tag, :canonical_url)
    # create unique_index(:mn_tag, :name, where: "deleted_at is null")

    # create table(:mn_tagging, primary_key: false) do
    #   add :id, references("mn_pointer", on_delete: :delete_all), primary_key: true
    #   add :canonical_url, :text
    #   add :tag_id, references("mn_tag", on_delete: :nilify_all)
    #   add :tagger_id, references("mn_user", on_delete: :nilify_all)
    #   add :tagged_id, references("mn_pointer", on_delete: :nilify_all)
    #   add :published_at, :timestamptz
    #   add :deleted_at, :timestamptz
    #   add :is_local, :boolean, null: false
    #   timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    # end

    # create index(:mn_tagging, :created_at)
    # create index(:mn_tagging, :updated_at)
    # create unique_index(:mn_tagging, :canonical_url)
    # create unique_index(:mn_tagging, [:tag_id, :tagger_id, :tagged_id], where: "deleted_at is null")
    # create index(:mn_tagging, :tagger_id, where: "deleted_at is null")
    # create index(:mn_tagging, :tagged_id, where: "deleted_at is null")

    create table(:mn_activity, primary_key: false) do
      add :id, references("mn_pointer", on_delete: :delete_all), primary_key: true
      add :canonical_url, :text
      add :user_id, references("mn_user", on_delete: :nilify_all)
      add :context_id, references("mn_pointer", on_delete: :nilify_all)
      add :verb, :text, null: false
      add :is_local, :boolean, null: false
      add :deleted_at, :timestamptz
      add :published_at, :timestamptz
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    create unique_index(:mn_activity, :canonical_url)
    create index(:mn_activity, :user_id)
    create index(:mn_activity, :context_id)
    create index(:mn_activity, :created_at)
    create index(:mn_activity, :updated_at)
    create index(:mn_activity, :published_at)

    create table(:mn_user_inbox, primary_key: false) do
      add :id, :text, primary_key: true
      add :user_id, references("mn_user", on_delete: :nilify_all)
      add :activity_id, references("mn_activity", on_delete: :nilify_all)
    end

    create index(:mn_user_inbox, :user_id)
    create index(:mn_user_inbox, :activity_id)

    create table(:mn_user_outbox, primary_key: false) do
      add :id, :text, primary_key: true
      add :user_id, references("mn_user", on_delete: :nilify_all)
      add :activity_id, references("mn_activity", on_delete: :nilify_all)
    end

    create index(:mn_user_outbox, :user_id)
    create index(:mn_user_outbox, :activity_id)

    create table(:mn_community_inbox, primary_key: false) do
      add :id, :text, primary_key: true
      add :community_id, references("mn_community", on_delete: :nilify_all)
      add :activity_id, references("mn_activity", on_delete: :nilify_all)
    end

    create index(:mn_community_inbox, :community_id)
    create index(:mn_community_inbox, :activity_id)

    create table(:mn_community_outbox, primary_key: false) do
      add :id, :text, primary_key: true
      add :community_id, references("mn_community", on_delete: :nilify_all)
      add :activity_id, references("mn_activity", on_delete: :nilify_all)
    end

    create index(:mn_community_outbox, :community_id)
    create index(:mn_community_outbox, :activity_id)

    create table(:mn_collection_inbox, primary_key: false) do
      add :id, :text, primary_key: true
      add :collection_id, references("mn_collection", on_delete: :nilify_all)
      add :activity_id, references("mn_activity", on_delete: :nilify_all)
    end

    create index(:mn_collection_inbox, :collection_id)
    create index(:mn_collection_inbox, :activity_id)

    create table(:mn_collection_outbox, primary_key: false) do
      add :id, :text, primary_key: true
      add :collection_id, references("mn_collection", on_delete: :nilify_all)
      add :activity_id, references("mn_activity", on_delete: :nilify_all)
    end

    create index(:mn_collection_outbox, :collection_id)
    create index(:mn_collection_outbox, :activity_id)

    create table(:mn_instance_inbox, primary_key: false) do
      add :id, :text, primary_key: true
      add :activity_id, references("mn_activity", on_delete: :nilify_all)
    end

    create index(:mn_instance_inbox, :activity_id)

    create table(:mn_instance_outbox, primary_key: false) do
      add :id, :text, primary_key: true
      add :activity_id, references("mn_activity", on_delete: :nilify_all)
    end

    create index(:mn_instance_outbox, :activity_id)

    create table(:mn_moodleverse_inbox, primary_key: false) do
      add :id, :text, primary_key: true
      add :activity_id, references("mn_activity", on_delete: :nilify_all)
    end

    create index(:mn_moodleverse_inbox, :activity_id)

    create table(:mn_moodleverse_outbox, primary_key: false) do
      add :id, :text, primary_key: true
      add :activity_id, references("mn_activity", on_delete: :nilify_all)
    end

    create index(:mn_moodleverse_outbox, :activity_id)

    create table(:access_token) do
      add :user_id, references("mn_user", on_delete: :delete_all), null: false
      add :expires_at, :timestamptz, null: false
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
    end

    # now we are going to do things with what we've already created.
    # ecto naturally wants to delay running any of this because we
    # might be running in mysql which doesn't have DDL transactions
    # as we happen to know we're not, carry on...
    flush()

    now = DateTime.utc_now()
    tables = Enum.map(@meta_tables, fn name ->
      %{"id" => Ecto.UUID.bingenerate(),
	"table" => name,
        "created_at" => now}
    end)
    Repo.insert_all("mn_table", tables)
    tables =
      Repo.all(from m in "mn_table", select: {m.id, m.table})
      |> Enum.reduce(%{}, fn {id, table}, acc ->
        Map.put(acc, table, id)
      end)
    
    lang_pointers = Enum.map(@languages, fn _ -> Ecto.UUID.bingenerate() end)
    {_, _} = Repo.insert_all(
      "mn_pointer",
      Enum.map(lang_pointers, fn id -> %{"id" => id, "table_id" => tables["mn_language"]} end)
    )
    langs =
      Enum.zip(lang_pointers, @languages)
      |> Enum.map(fn {ptr, {code2, code3, name, name2}} ->
        %{"id" => ptr,
          "iso_code2" => code2,
          "iso_code3" => code3,
          "english_name" => name,
          "local_name" => name2,
          "created_at" => now,
          "updated_at" => now}
      end)
    Repo.insert_all("mn_language", langs)

    country_pointers = Enum.map(@countries, fn _ -> Ecto.UUID.bingenerate() end)
    {_, _} = Repo.insert_all(
      "mn_pointer",
      Enum.map(country_pointers, fn id -> %{"id" => id, "table_id" => tables["mn_country"]} end)
    )
    countries =
      Enum.zip(country_pointers, @countries)
      |> Enum.map(fn {pointer, {code2, code3, name, name2}} ->
        %{"id" => pointer,
          "iso_code2" => code2,
          "iso_code3" => code3,
          "english_name" => name,
          "local_name" => name2,
          "created_at" => now,
          "updated_at" => now}
        end)
    Repo.insert_all("mn_country", countries)

    # cats_pointers = Enum.map(@tag_categories, fn _ -> Ecto.UUID.bingenerate() end)
    # {_, _} = Repo.insert_all(
    #   "mn_pointer",
    #   Enum.map(cats_pointers, fn id -> %{"id" => id, "table_id" => tables["mn_tag_category"]} end)
    # )
    # cats =
    #   Enum.zip(cats_pointers, @tag_categories)
    #   |> Enum.map(fn {pointer, cat} ->
    #     %{"id" => pointer,
    #       "name" => cat,
    #       "created_at" => now,
    #       "updated_at" => now,
    #       "published_at" => now}
    #   end)
    # Repo.insert_all("mn_tag_category", cats)

    ### last activity views

    # user

    :ok = execute """
    create view mn_user_last_activity as
    select
      distinct on (user_id)
      id, user_id
    from mn_user_outbox
    order by user_id, id desc
    """

    # community

    :ok = execute """
    create view mn_community_last_activity as
    select
      distinct on (community_id)
      id, community_id
    from mn_community_outbox
    order by community_id, id desc
    """

    # collection

    :ok = execute """
    create view mn_collection_last_activity as
    select
      distinct on (collection_id)
      id, collection_id
    from mn_collection_outbox
    order by collection_id, id desc
    """

    # thread

    :ok = execute """
    create view mn_thread_last_activity as
    select distinct on (thread_id)
      thread_id, updated_at
    from mn_comment
    order by thread_id, updated_at desc
    """

    ### follower counts

    # user

    :ok = execute """
    create view mn_user_follower_count as
    select mn_user.id as user_id,
           coalesce(count(mn_follow.follower_id), 0) as count
    from mn_user left join mn_follow on mn_user.id = mn_follow.followed_id
    where mn_follow.deleted_at is null
    group by mn_user.id
    """

    # community

    :ok = execute """
    create view mn_community_follower_count as
    select mn_community.id as community_id,
           coalesce(count(mn_follow.follower_id), 0) as count
    from mn_community left join mn_follow on mn_community.id = mn_follow.followed_id
    where mn_follow.deleted_at is null
    group by mn_community.id
    """

    # collection

    :ok = execute """
    create view mn_collection_follower_count as
    select mn_collection.id as collection_id,
           coalesce(count(mn_follow.follower_id), 0) as count
    from mn_collection left join mn_follow on mn_collection.id = mn_follow.followed_id
    where mn_follow.deleted_at is null
    group by mn_collection.id
    """

    # thread
    
    :ok = execute """
    create view mn_thread_follower_count as
    select mn_thread.id as thread_id,
           coalesce(count(mn_follow.follower_id), 0) as count
    from mn_thread left join mn_follow on mn_thread.id = mn_follow.followed_id
    where mn_follow.deleted_at is null
    group by mn_thread.id
    """

    ### following counts

    # user

    :ok = execute """
    create view mn_user_following_count as
    select mn_user.id as user_id,
           coalesce(count(mn_follow.followed_id), 0) as count
    from mn_user left join mn_follow on mn_user.id = mn_follow.follower_id
    where mn_follow.deleted_at is null
    group by mn_user.id
    """

  end

  def down do

    :ok = execute "drop view mn_user_following_count"
    :ok = execute "drop view mn_thread_follower_count"
    :ok = execute "drop view mn_collection_follower_count"
    :ok = execute "drop view mn_community_follower_count"
    :ok = execute "drop view mn_user_follower_count"
    flush()
    drop table(:access_token)

    drop index(:mn_moodleverse_inbox, :created_at)
    drop index(:mn_moodleverse_inbox, :activity_id)
    drop table(:mn_moodleverse_inbox)

    drop index(:mn_moodleverse_outbox, :created_at)
    drop index(:mn_moodleverse_outbox, :activity_id)
    drop table(:mn_moodleverse_outbox)

    drop table(:mn_instance_inbox)
    drop index(:mn_instance_inbox, :created_at)
    drop index(:mn_instance_inbox, :activity_id)

    drop table(:mn_instance_outbox)
    drop index(:mn_instance_outbox, :created_at)
    drop index(:mn_instance_outbox, :activity_id)

    drop index(:mn_collection_outbox, :created_at)
    drop index(:mn_collection_outbox, :collection_id)
    drop index(:mn_collection_outbox, :activity_id)
    drop table(:mn_collection_outbox)

    drop index(:mn_collection_inbox, :created_at)
    drop index(:mn_collection_inbox, :collection_id)
    drop index(:mn_collection_inbox, :activity_id)
    drop table(:mn_collection_inbox)

    drop index(:mn_community_inbox, :created_at)
    drop index(:mn_community_inbox, :community_id)
    drop index(:mn_community_inbox, :activity_id)
    drop table(:mn_community_inbox)

    drop index(:mn_community_outbox, :created_at)
    drop index(:mn_community_outbox, :community_id)
    drop index(:mn_community_outbox, :activity_id)
    drop table(:mn_community_outbox)

    drop index(:mn_user_inbox, :created_at)
    drop index(:mn_user_inbox, :user_id)
    drop index(:mn_user_inbox, :activity_id)
    drop table(:mn_user_inbox)

    drop index(:mn_user_outbox, :created_at)
    drop index(:mn_user_outbox, :user_id)
    drop index(:mn_user_outbox, :activity_id)
    drop table(:mn_user_outbox)

    drop index(:mn_activity, :canonical_url)
    drop index(:mn_activity, :user_id)
    drop index(:mn_activity, :context_id)
    drop index(:mn_activity, :created_at)
    drop index(:mn_activity, :updated_at)
    drop index(:mn_activity, :published_at)
    drop table(:mn_activity)
    
    # drop index(:mn_tagging, :created_at)
    # drop index(:mn_tagging, :updated_at)
    # drop index(:mn_tagging, :canonical_url)
    # drop index(:mn_tagging, [:tag_id, :tagger_id, :tagged_id])
    # drop index(:mn_tagging, :tagger_id)
    # drop index(:mn_tagging, :tagged_id)
    # drop table(:mn_tagging)

    # drop index(:mn_tag, :created_at)
    # drop index(:mn_tag, :updated_at)
    # drop index(:mn_tag, :canonical_url)
    # drop index(:mn_tag, :name)
    # drop table(:mn_tag)

    # drop index(:mn_tag_category, :created_at)
    # drop index(:mn_tag_category, :updated_at)
    # drop index(:mn_tag_category, :canonical_url)
    # drop index(:mn_tag_category, :name)
    # drop table(:mn_tag_category)

    drop index(:mn_block, :created_at)
    drop index(:mn_block, :updated_at)
    drop index(:mn_block, :canonical_url)
    drop index(:mn_block, [:blocker_id, :blocked_id])
    drop index(:mn_block, :blocked_id)
    drop table(:mn_block)

    drop index(:mn_follow, :created_at)
    drop index(:mn_follow, :updated_at)
    drop index(:mn_follow, :canonical_url)
    drop index(:mn_follow,[:follower_id, :followed_id])
    drop index(:mn_follow, :followed_id)
    drop table(:mn_follow)

    drop index(:mn_like, :created_at)
    drop index(:mn_like, :updated_at)
    drop index(:mn_like, :canonical_url)
    drop index(:mn_like, [:liker_id, :liked_id])
    drop index(:mn_like, :liked_id)
    drop table(:mn_like)

    drop index(:mn_flag, :created_at)
    drop index(:mn_flag, :updated_at)
    drop index(:mn_flag, :canonical_url)
    drop index(:mn_flag, [:flagger_id, :flagged_id])
    drop index(:mn_flag, :flagged_id)
    drop index(:mn_flag, :community_id)
    drop table(:mn_flag)

    drop index(:mn_comment, :created_at)
    drop index(:mn_comment, :updated_at)
    drop index(:mn_comment, :canonical_url)
    drop index(:mn_comment, :creator_id)
    drop index(:mn_comment, :thread_id)
    drop table(:mn_comment)

    drop index(:mn_thread, :created_at)
    drop index(:mn_thread, :updated_at)
    drop index(:mn_thread, :canonical_url)
    drop index(:mn_thread, :creator_id)
    drop index(:mn_thread, :context_id)
    drop table(:mn_thread)

    drop index(:mn_resource, :created_at)
    drop index(:mn_resource, :updated_at)
    drop index(:mn_resource, :canonical_url)
    drop index(:mn_resource, :creator_id)
    drop index(:mn_resource, :collection_id)
    drop index(:mn_resource, :primary_language_id)
    drop table(:mn_resource)

    drop index(:mn_collection, :created_at)
    drop index(:mn_collection, :updated_at)
    drop index(:mn_collection, :actor_id)
    drop index(:mn_collection, :creator_id)
    drop index(:mn_collection, :community_id)
    drop index(:mn_collection, :primary_language_id)
    drop table(:mn_collection)

    drop index(:mn_community, :created_at)
    drop index(:mn_community, :updated_at)
    drop index(:mn_community, :creator_id)
    drop index(:mn_community, :actor_id)
    drop index(:mn_community, :primary_language_id)
    drop table(:mn_community)

    drop index(:mn_user, :actor_id)
    drop index(:mn_user, :local_user_id)
    drop index(:mn_user, :primary_language_id)
    drop table(:mn_user)

    drop index(:mn_local_user_email_confirm_token, :local_user_id)
    drop table(:mn_local_user_email_confirm_token)

    drop index(:mn_local_user_reset_password_token, :local_user_id)
    drop table(:mn_local_user_reset_password_token)
    
    drop index(:mn_local_user, :email)
    drop table(:mn_local_user, :email)

    drop index(:mn_actor, [:preferred_username, :peer_id], name: :mn_actor_preferred_username_peer_id_index)
    drop index(:mn_actor, [:preferred_username], name: :mn_actor_peer_id_null_index)
    drop index(:mn_actor, :peer_id)
    drop index(:mn_actor, :canonical_url)
    drop table(:mn_actor)

    drop index(:mn_peer, :ap_url_base)
    drop index(:mn_peer, :ap_url_base)
    drop table(:mn_peer)

    drop index(:mn_access_register_email, :email)
    drop table(:mn_access_register_email)

    drop index(:mn_access_register_email_domain, :domain)
    drop table(:mn_access_register_email_domain)

    drop index(:mn_language, :iso_code2)
    drop index(:mn_language, :iso_code3)
    drop table(:mn_language)

    drop index(:mn_country, :iso_code2)
    drop index(:mn_country, :iso_code3)
    drop table(:mn_country)

    drop index(:mn_pointer, :table_id)
    drop table(:mn_pointer)

    drop index(:mn_table, :table)
    drop table(:mn_table)
  end

end
