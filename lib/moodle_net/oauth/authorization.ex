# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.OAuth.Authorization do
  @moduledoc """
  An authorization is what allows you to claim a token
  """
  use MoodleNet.Common.Schema
  alias MoodleNet.OAuth.Token
  alias MoodleNet.Users.User
  alias Ecto.Changeset
  alias MoodleNet.Common.Changeset, as: Changeset2

  @default_validity 60 * 10 # seconds: this seems short, but it's what alex set it to

  standalone_schema "oauth_authorizations" do
    belongs_to :user, User
    field :expires_at, :utc_datetime_usec
    field :claimed_at, :utc_datetime_usec
    timestamps()
  end

  def create_changeset(user_id, validity \\ @default_validity) do
    %__MODULE__{}
    |> Changeset.cast(%{}, [])
    |> Changeset.change(user_id: user_id, expires_at: expires_at(validity))
    |> Changeset.foreign_key_constraint(:user_id)
  end

  def claim_changeset(auth), do: Changeset2.claim_changeset(auth, :claimed_at)

  defp expires_at(validity), do: DateTime.add(DateTime.utc_now(), validity)

end
