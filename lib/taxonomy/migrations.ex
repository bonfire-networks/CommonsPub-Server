defmodule Taxonomy.Migrations do
  use Ecto.Migration

  require Logger
  alias Ecto.ULID
  alias MoodleNet.Repo

  def dotsql_execute(filename) do
    sqlines = String.split(File.read!(filename), ";\n")
    Enum.each(sqlines, &execute/1)

  end

  def try_dotsql_execute(filename) do
    case File.stat(filename) do
      {:ok, _} -> dotsql_execute(filename)
      {:error, :enoent} -> Logger.info("SQL file for taxonomy module not found: "<>filename)
    end
  end

  @meta_tables [] ++ ~w(taxonomy_tags) 

  def add_pointer do
    alter table(:taxonomy_tags) do
      add_if_not_exists :pointer_id, :uuid
    end
  end

  def init_pointer do

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

  def remove_pointer do

    alter table(:taxonomy_tags) do
      remove_if_exists :pointer_id, :uuid
    end

    table = "taxonomy_tags"
    MoodleNet.ReleaseTasks.remove_meta_table(table)

  end



  def up do

    try_dotsql_execute("lib/taxonomy/sql/tags.schema.sql")
    try_dotsql_execute("data/sql/tags.data.sql")


  end

  def down do

    try_dotsql_execute("lib/taxonomy/sql/tags.down.sql")

  end


end
