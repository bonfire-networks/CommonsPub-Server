# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Accounts.WhitelistEmail do
  @moduledoc """
  Model to store the emails allowed to sign up
  """
  use Ecto.Schema

  @primary_key false
  schema "accounts_whitelist_emails" do
    field(:email, :string, primary_key: true)
  end
end
