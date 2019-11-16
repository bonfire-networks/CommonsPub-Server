# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.Me do
  @enforce_keys [
    :email, :wants_email_digest, :wants_notifications,
    :is_instance_admin, :is_confirmed, :user,
  ]
  defstruct @enforce_keys

  def new(user) do
    %__MODULE__{
      user: user,
      email: user.local_user.email,
      wants_email_digest: user.local_user.wants_email_digest,
      wants_notifications: user.local_user.wants_notifications,
      is_instance_admin: user.local_user.is_instance_admin,
      is_confirmed: user.local_user.is_confirmed,
    }
  end

end
