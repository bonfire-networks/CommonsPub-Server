# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.ResetPasswordToken do
  use MoodleNet.Common.Schema

  alias Ecto.Changeset
  alias MoodleNet.Users.LocalUser
  import MoodleNet.Common.Changeset, only: [claim_changeset: 3]

  @type t :: %__MODULE__{}

  @default_validity {60 * 60 * 48, :second}

  standalone_schema "mn_local_user_reset_password_token" do
    belongs_to(:local_user, LocalUser)
    field(:expires_at, :utc_datetime_usec)
    field(:reset_at, :utc_datetime_usec)
    timestamps()
  end

  def create_changeset(user, validity_period \\ @default_validity)

  def create_changeset(%LocalUser{} = user, validity) do
    %__MODULE__{}
    |> Changeset.cast(%{}, [])
    |> Changeset.put_change(:local_user, user.id)
    |> Changeset.put_change(:expires_at, expires_at(validity))
  end

  def claim_changeset(%__MODULE__{} = token),
    do: MoodleNet.Common.Changeset.claim_changeset(token, :reset_at)

  defp expires_at({count, unit}) when is_integer(count) and count > 0,
    do: DateTime.add(DateTime.utc_now(), count, unit)
end
