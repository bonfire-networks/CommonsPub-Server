# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
defmodule MoodleNet.Repo.Migrations.AddThreadTitle do
  use Ecto.Migration

  def change do
    alter table("mn_thread") do
      add(:name, :string)
    end

    alter table("mn_comment") do
      add(:name, :string)
    end
  end
end
