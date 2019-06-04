# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.OAuth.Authorization do
  use Ecto.Schema

  alias Ecto.Changeset

  schema "oauth_authorizations" do
    field(:hash, :string)
    field(:valid_until, :naive_datetime_usec)
    field(:used, :boolean, default: false)
    belongs_to(:user, MoodleNet.Accounts.User)
    belongs_to(:app, MoodleNet.OAuth.App)

    timestamps()
  end

  def build(user_id, app_id) do
    hash = MoodleNet.Token.random_key()

    %__MODULE__{}
    |> Changeset.change(
      hash: hash,
      used: false,
      user_id: user_id,
      app_id: app_id,
      valid_until: expiration_time()
    )
    |> Changeset.foreign_key_constraint(:user_id)
    |> Changeset.foreign_key_constraint(:app_id)
  end

  defp expiration_time(), do: NaiveDateTime.add(NaiveDateTime.utc_now(), 60 * 10)

  def use_changeset(%__MODULE__{used: true} = auth) do
    auth
    |> Changeset.change()
    |> Changeset.add_error(:used, "already used")
  end

  def use_changeset(%__MODULE__{} = auth) do
    if expired?(auth) do
      auth
      |> Changeset.change()
      |> Changeset.add_error(:valid_until, "expired")
    else
      Changeset.change(auth, used: true)
    end
  end

  def expired?(%__MODULE__{valid_until: valid_until}),
    do: NaiveDateTime.compare(valid_until, NaiveDateTime.utc_now()) == :gt
end
