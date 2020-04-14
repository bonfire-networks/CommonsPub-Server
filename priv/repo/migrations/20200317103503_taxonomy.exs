defmodule MoodleNet.Repo.Migrations.Taxonomy do
  use Ecto.Migration

  require Logger

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


  def up do

    try_dotsql_execute("lib/taxonomy/migrations/tags.schema.sql")
    try_dotsql_execute("uploads/db_data/tags.data.sql")


  end

  def down do

    try_dotsql_execute("lib/taxonomy/migrations/tags.down.sql")

  end

end
