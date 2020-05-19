# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
defmodule MoodleNet.Repo.Migrations.ChangeMnContentVarcharToText do
  use Ecto.Migration

  def change do
    alter table(:mn_content) do
      modify :media_type, :text
    end

    alter table(:mn_content_upload) do
      modify :path, :text
    end

    alter table(:mn_content_mirror) do
      modify :url, :text
    end
  end
end
