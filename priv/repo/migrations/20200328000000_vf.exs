defmodule MoodleNet.Repo.Migrations.VF do
    use Ecto.Migration

    def change do
        ValueFlows.Migrations.change()
    end

    # def up do
    #   ValueFlows.Migrations.up()
    # end

    # # We specify `version: 1` in `down`, ensuring that we'll roll all the way back down if
    # # necessary, regardless of which version we've migrated `up` to.
    # def down do
    #   ValueFlows.down(version: 1)
    # end
end
