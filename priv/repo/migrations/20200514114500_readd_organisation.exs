defmodule MoodleNet.Repo.Migrations.ReaddOrganisation do
    use Ecto.Migration

    def up do
      Organisation.Migrations.up()
    end

    def down do
      Organisation.Migrations.down()
    end
end
