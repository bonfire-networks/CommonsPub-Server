# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.OAuth.Token do
  @moduledoc """
  OAuth token model
  """
  use Ecto.Schema

  alias Ecto.Changeset

  schema "oauth_tokens" do
    field(:hash, :string)
    field(:refresh_hash, :string)
    field(:valid_until, :naive_datetime_usec)
    belongs_to(:user, MoodleNet.Accounts.User)
    belongs_to(:app, MoodleNet.OAuth.App)

    timestamps()
  end

  def build(app_id, user_id) do
    hash = MoodleNet.Token.random_key_with_id(user_id)
    refresh_hash = MoodleNet.Token.random_key_with_id(user_id)

    Changeset.change(%__MODULE__{},
      hash: hash,
      refresh_hash: refresh_hash,
      user_id: user_id,
      app_id: app_id,
      valid_until: expiration_time()
    )
    |> Changeset.validate_required([:user_id, :app_id])
  end

  defp expiration_time(), do: NaiveDateTime.add(NaiveDateTime.utc_now(), 60 * 10)
end
