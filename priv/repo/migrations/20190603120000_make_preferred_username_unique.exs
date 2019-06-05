# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Repo.Migrations.MakePreferredUsernameUnique do
  use ActivityPub.Migration

  def change do
    create unique_index(:activity_pub_actor_aspects, :preferred_username)
  end
end
