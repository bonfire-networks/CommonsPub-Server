defmodule CommonsPub.Character.Migrations do
  import Ecto.Migration
  import Pointers.Migration

  defp table_name(), do: CommonsPub.Character.__schema__(:source)

  # IO.inspect(cs: Character.__schema__(:source))

  def migrate(index_opts, :up) do
    # a character is a group actor that is home to resources
    create_mixin_table(CommonsPub.Character) do
      # add table_name()istic_id, :uuid # points to the Thing that this character represents
      # points to the Actor who plays this character in the fediverse
      add(:actor_id, references("mn_actor", on_delete: :delete_all))

      # add :context_id, weak_pointer(), null: true # points to the parent Thing of this character
      add(:facet, :string)
      add(:inbox_id, references("mn_feed", on_delete: :nilify_all))
      add(:outbox_id, references("mn_feed", on_delete: :nilify_all))
      # add(:name, :string)
      # add(:summary, :text)
      add(:extra_info, :map)
      add(:icon_id, references(:mn_content))
      add(:image_id, references(:mn_content))
      # add :primary_language_id, references("languages", on_delete: :nilify_all)
      add(:creator_id, references("mn_user", on_delete: :nilify_all))
      add(:published_at, :timestamptz)
      add(:deleted_at, :timestamptz)
      add(:disabled_at, :timestamptz)
      # timestamps(inserted_at: false, type: :utc_datetime_usec)
    end

    flush()

    # create_if_not_exists(index(table_name(), :updated_at, index_opts))
    create_if_not_exists(index(table_name(), :actor_id, index_opts))
    create_if_not_exists(index(table_name(), :creator_id, index_opts))

    # create_if_not_exists index(table_name(), :context_id)
    # create_if_not_exists index(table_name(), :primary_language_id)

    :ok =
      execute("""
      create or replace view character_last_activity as
      select character.id as character_id, max(mn_feed_activity.id) as activity_id
      from character left join mn_feed_activity
      on character.outbox_id = mn_feed_activity.feed_id
      group by character.id
      """)
  end

  def migrate(index_opts, :down) do
    :ok = execute("drop view if exists character_last_activity")

    drop_if_exists(index(table_name(), :updated_at, index_opts))
    drop_if_exists(index(table_name(), :actor_id, index_opts))
    drop_if_exists(index(table_name(), :creator_id, index_opts))
    drop_if_exists(index(table_name(), :community_id, index_opts))
    drop_if_exists(index(table_name(), :primary_language_id, index_opts))
    drop_mixin_table(table_name())
  end

  def name_reservation_change() do
    create table("actor_name_reservation", primary_key: false) do
      add(:id, :bytea, primary_key: true, null: false)
      timestamps(type: :utc_datetime_usec, inserted_at: :created_at, updated_at: false)
    end
  end

  def merge_with_actor() do
    rename(table("mn_actor"), to: table("mn_actor_archived"))
    flush()

    # rename(table("character"), to: table("mn_actor"))
    # flush()

    CommonsPub.Repo.delete_all(table_name())

    alter table(table_name()) do
      add(:peer_id, references("mn_peer", on_delete: :delete_all))
      add(:preferred_username, :citext, null: false)
      add(:canonical_url, :text)
      add(:signing_key, :text)
    end

    create(
      unique_index(
        table_name(),
        [:preferred_username, :peer_id],
        name: :character_preferred_username_peer_id_index
      )
    )

    create(
      unique_index(
        table_name(),
        [:preferred_username],
        where: "peer_id is null",
        name: :character_peer_id_null_index
      )
    )
  end
end
