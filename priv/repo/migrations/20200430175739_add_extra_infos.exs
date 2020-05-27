# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
defmodule MoodleNet.Repo.Migrations.AddExtraInfos do
  use Ecto.Migration

  def change do

    alter table("mn_community") do
      add :extra_info, :map
    end

    alter table("mn_collection") do
      add :extra_info, :map
    end

    alter table("mn_resource") do
      add :extra_info, :map
    end

  end
end
