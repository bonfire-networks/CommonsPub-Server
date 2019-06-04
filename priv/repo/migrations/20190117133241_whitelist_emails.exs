# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Repo.Migrations.WhitelistEmails do
  use Ecto.Migration

  def change do
    create table(:accounts_whitelist_emails, primary_key: false) do
      add :email, :citext, null: false, primary_key: true
    end
  end
end
