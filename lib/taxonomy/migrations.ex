defmodule Taxonomy.Migrations do
  use Ecto.Migration

  require Logger

  # alias Ecto.ULID
  alias MoodleNet.Repo

  @extension_path "lib/taxonomy"

  def try_dotsql_execute(filename, mode) do
    path = "/opt/app/" <> filename

    case File.stat(path) do
      {:ok, _} ->
        dotsql_execute(path, mode)

      {:error, :enoent} ->
        Logger.info("SQL file for taxonomy module not found: " <> path)

        path = @extension_path <> "/overlay/" <> filename

        case File.stat(path) do
          {:ok, _} ->
            dotsql_execute(path, mode)

          {:error, :enoent} ->
            Logger.info("SQL file for taxonomy module not found: " <> path)

            path = filename

            case File.stat(path) do
              {:ok, _} -> dotsql_execute(path, mode)
              {:error, :enoent} -> Logger.warn("SQL file for taxonomy module not found: " <> path)
            end
        end
    end
  end

  def dotsql_execute(filename, mode) do
    sqlines = String.split(File.read!(filename), ";\n")
    Enum.each(sqlines, &sql_execute(&1, mode))
    flush()
  end

  def sql_execute(sql, :migration) do
    execute(sql)
    flush()
  end

  def sql_execute(sql, :seed) do
    Ecto.Adapters.SQL.query!(
      Repo,
      sql
    )
  end

  # cleanup deprecated stuff
  def remove_pointer do
    table = "taxonomy_tag"

    alter table(table) do
      remove_if_exists(:pointer_id, :uuid)
    end

    Pointers.Migration.drop_pointer_trigger(table)
    MoodleNet.ReleaseTasks.remove_meta_table(table)
  end

  def up do
    execute("DROP TABLE IF EXISTS taxonomy_tags CASCADE")
    try_dotsql_execute("tags.schema.sql", :migration)
    ingest_data(:migration)
  end

  def ingest_data(mode) do
    try_dotsql_execute("data/sql/tags.data.sql", mode)
  end

  def down do
    try_dotsql_execute("tags.down.sql", :migration)
  end
end
