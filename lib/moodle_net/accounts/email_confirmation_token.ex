# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Accounts.EmailConfirmationToken do
  @moduledoc """
  Model to store the email confirmation tokens
  """
  use Ecto.Schema

  alias MoodleNet.Accounts.User

  schema "accounts_email_confirmation_tokens" do
    belongs_to(:user, User)
    field(:token, :string)

    timestamps(updated_at: false)
  end

  def build_changeset(user_id) do
    token = MoodleNet.Token.random_key_with_id(user_id)
    Ecto.Changeset.change(%__MODULE__{}, user_id: user_id, token: token)
  end
end
