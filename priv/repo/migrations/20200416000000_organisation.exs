defmodule MoodleNet.Repo.Migrations.Organisation do
    use Ecto.Migration

    # def change do
    #     Organisation.Migrations.change()
    # end

    def up do
      Organisation.Migrations.up()
    end

    def down do
      Organisation.Migrations.down()
    end
end
