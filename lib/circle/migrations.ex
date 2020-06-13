defmodule Circle.Migrations do

  use Ecto.Migration
  alias MoodleNet.Repo
  alias Ecto.ULID

  @meta_tables [] ++ ~w(circle) 

  def up do

    # deprecated

  end

  def up_pointer do

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

  end

  def down do # remove deprecated table

      :ok = execute "drop view if exists mn_organisation_last_activity"

      drop_if_exists index(:mn_organisation, :updated_at)
      drop_if_exists index(:mn_organisation, :actor_id)
      drop_if_exists index(:mn_organisation, :creator_id)
      drop_if_exists index(:mn_organisation, :community_id)
      drop_if_exists index(:mn_organisation, :primary_language_id)
      drop_if_exists table(:mn_organisation)

      MoodleNet.ReleaseTasks.remove_meta_table("mn_organisation")

  end

  def change_simpler(:up) do

    # a circle is a group actor that is home to resources
    create_if_not_exists table(:circle) do
      add :character_id, references("character", on_delete: :delete_all)
      add :extra_info, :map
    end

  end

  def change_simpler(:down) do
    drop_if_exists table(:circle)
  end

end
