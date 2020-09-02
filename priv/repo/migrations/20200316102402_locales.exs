defmodule CommonsPub.Repo.Migrations.Locales do
  use Ecto.Migration

  def up do
    # IO.inspect(:application.get_key(:commons_pub, :modules), limit: :infinity)

    Locales.Migrations.up()
  end

  def down do
    Locales.Migrations.down()
  end
end
