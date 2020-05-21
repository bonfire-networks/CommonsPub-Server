# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
defmodule MoodleNet.Repo.Migrations.FeedDeletion do
  use Ecto.Migration

  def change do

    alter table("mn_feed") do
      add :deleted_at, :timestamptz
    end

  end

end
