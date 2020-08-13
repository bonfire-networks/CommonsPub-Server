defmodule Geolocation.Migrations do
  use Ecto.Migration
  alias MoodleNet.Repo
  alias Ecto.ULID

  @meta_tables [] ++ ~w(geolocation)

  def change do
    :ok =
      execute(
        "create extension IF NOT EXISTS postgis;",
        "drop extension postgis;"
      )

    create table(:geolocation) do
      add(:name, :string)
      add(:note, :text)
      add(:mappable_address, :string)
      add(:geom, :geometry)
      add(:alt, :float)

      add(:actor_id, references("mn_actor", on_delete: :delete_all))

      # add :community_id, references("mn_community", on_delete: :delete_all) # replaced with context
      add(:context_id, references("mn_pointer", on_delete: :delete_all))
      add(:creator_id, references("mn_user", on_delete: :nilify_all))
      add(:inbox_id, references("mn_feed", on_delete: :nilify_all))
      add(:outbox_id, references("mn_feed", on_delete: :nilify_all))
      add(:published_at, :timestamptz)
      add(:deleted_at, :timestamptz)
      add(:disabled_at, :timestamptz)

      timestamps(inserted_at: false, type: :utc_datetime_usec)
    end
  end

  def add_pointer do
    tables =
      Enum.map(@meta_tables, fn name ->
        %{"id" => ULID.bingenerate(), "table" => name}
      end)

    {_, _} = Repo.insert_all("mn_table", tables)

    _tables =
      Enum.reduce(tables, %{}, fn %{"id" => id, "table" => table}, acc ->
        Map.put(acc, table, id)
      end)

    for table <- @meta_tables do
      :ok =
        execute("""
        create trigger "insert_pointer_#{table}"
        before insert on "#{table}"
        for each row
        execute procedure insert_pointer()
        """)
    end
  end
end
