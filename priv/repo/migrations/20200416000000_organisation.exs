defmodule MoodleNet.Repo.Migrations.Organisation do
    use Ecto.Migration

    # def change do
    #     Organisation.Migrations.change()
    # end

    def up do
      Organisation.Migrations.up()
    end

    # We specify `version: 1` in `down`, ensuring that we'll roll all the way back down if
    # necessary, regardless of which version we've migrated `up` to.
    def down do
      Organisation.Migrations.down()
    end
end
