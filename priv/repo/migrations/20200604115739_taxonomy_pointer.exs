# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
defmodule MoodleNet.Repo.Migrations.TaxonomyPointer do
  use Ecto.Migration

  def up do
    Taxonomy.Migrations.add_pointer()
    Taxonomy.Migrations.init_pointer()

  end

  def down do

    Taxonomy.Migrations.remove_pointer()

  end


end
