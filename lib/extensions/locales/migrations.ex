defmodule Locales.Migrations do
  use Ecto.Migration

  require Logger

  @extension_path "lib/extensions/locales"

  def try_dotsql_execute(filename) do
    path = "/opt/app/" <> filename

    case File.stat(path) do
      {:ok, _} ->
        dotsql_execute(path)

      {:error, :enoent} ->
        Logger.info("SQL file for taxonomy module not found: " <> path)

        path = @extension_path <> "/overlay/" <> filename

        case File.stat(path) do
          {:ok, _} ->
            dotsql_execute(path)

          {:error, :enoent} ->
            Logger.info("SQL file for taxonomy module not found: " <> path)

            path = filename

            case File.stat(path) do
              {:ok, _} -> dotsql_execute(path)
              {:error, :enoent} -> Logger.warn("SQL file for taxonomy module not found: " <> path)
            end
        end
    end
  end

  def dotsql_execute(filename) do
    sqlines = String.split(File.read!(filename), ";\n")
    Enum.each(sqlines, &sql_execute/1)
    flush()
  end

  def sql_execute(sql) do
    execute(sql)
    flush()
  end

  def up do
    try_dotsql_execute("locales.schema.sql")
    try_dotsql_execute("data/sql/locales.data.sql")
  end

  def down do
    try_dotsql_execute("locales.down.sql")
  end
end
