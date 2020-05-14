defmodule Organisation.Migrations do

  use Ecto.Migration
  alias MoodleNet.Repo
  alias Ecto.ULID

  @meta_tables [] ++ ~w(mn_organisation) 

  def up do

    # a organisation is a group actor that is home to resources
    create_if_not_exists table(:mn_organisation) do
      add :actor_id, references("mn_actor", on_delete: :delete_all)
      add :creator_id, references("mn_user", on_delete: :nilify_all)
      add :community_id, references("mn_community", on_delete: :nilify_all)
      add :primary_language_id, references("mn_language", on_delete: :nilify_all)
      add :inbox_id, references("mn_feed", on_delete: :nilify_all)
      add :outbox_id, references("mn_feed", on_delete: :nilify_all)
      add :icon_id, references(:mn_content)
      add :name, :text
      add :summary, :text
      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      add :disabled_at, :timestamptz
      timestamps(inserted_at: false, type: :utc_datetime_usec)
    end

    create_if_not_exists index(:mn_organisation, :updated_at)
    create_if_not_exists index(:mn_organisation, :actor_id)
    create_if_not_exists index(:mn_organisation, :creator_id)
    create_if_not_exists index(:mn_organisation, :community_id)
    create_if_not_exists index(:mn_organisation, :primary_language_id)


    tables = Enum.map(@meta_tables, fn name ->
        %{"id" => ULID.bingenerate(), "table" => name}
      end)
      {_, _} = Repo.insert_all("mn_table", tables)
      tables = Enum.reduce(tables, %{}, fn %{"id" => id, "table" => table}, acc ->
        Map.put(acc, table, id)
    end)

    for table <- @meta_tables do
        :ok = execute """
        create trigger "insert_pointer_#{table}"
        before insert on "#{table}"
        for each row
        execute procedure insert_pointer()
        """
    end


    :ok = execute """
    create view mn_organisation_last_activity as
    select mn_organisation.id as organisation_id, max(mn_feed_activity.id) as activity_id
    from mn_organisation left join mn_feed_activity
    on mn_organisation.outbox_id = mn_feed_activity.feed_id
    group by mn_organisation.id
    """

  end

  def down do

      :ok = execute "drop view if exists mn_organisation_last_activity"

      drop_if_exists index(:mn_organisation, :updated_at)
      drop_if_exists index(:mn_organisation, :actor_id)
      drop_if_exists index(:mn_organisation, :creator_id)
      drop_if_exists index(:mn_organisation, :community_id)
      drop_if_exists index(:mn_organisation, :primary_language_id)
      drop_if_exists table(:mn_organisation)

      MoodleNet.ReleaseTasks.remove_meta_table("mn_organisation")
      MoodleNet.ReleaseTasks.remove_meta_table("organisation") # oops

      MoodleNet.ReleaseTasks.remove_meta_table("organisation")

  end

end
