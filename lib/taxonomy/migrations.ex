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

  def remove_pointer do # cleanup deprecated stuff
    table = "taxonomy_tag"

    alter table(table) do
      remove_if_exists :pointer_id, :uuid
    end

    Pointers.Migration.drop_pointer_trigger(table)
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
