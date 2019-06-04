# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Accounts.ResetPasswordToken do
  use Ecto.Schema

  alias MoodleNet.Accounts.User

  schema "accounts_reset_password_tokens" do
    belongs_to(:user, User)
    field(:token, :string)

    timestamps(updated_at: false)
  end

  def build_changeset(%User{} = user) do
    token = MoodleNet.Token.random_key_with_id(user.id)
    Ecto.Changeset.change(%__MODULE__{}, user_id: user.id, token: token)
  end
end
