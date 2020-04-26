defmodule Measurement.Migrations do
  use Ecto.Migration
  alias MoodleNet.Repo
  alias Ecto.ULID

  @meta_tables [] ++ ~w(unit measure) 

  def change do
    create table(:unit) do

      add :label, :string
      add :symbol, :string

      add :community_id, references("mn_community", on_delete: :delete_all)
      add :creator_id, references("mn_user", on_delete: :nilify_all)

      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      add :disabled_at, :timestamptz

      timestamps(inserted_at: false, type: :utc_datetime_usec)

    end

  end

  def change_measure do
    create table(:measure) do

      add :hasNumericalValue, :float

      add :unit_id, references("unit", on_delete: :delete_all)
      add :creator_id, references("mn_user", on_delete: :nilify_all)

      add :published_at, :timestamptz
      add :deleted_at, :timestamptz
      add :disabled_at, :timestamptz

      timestamps(inserted_at: false, type: :utc_datetime_usec)

    end

  end

  def add_pointer do
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


end
