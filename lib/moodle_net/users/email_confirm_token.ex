# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.EmailConfirmToken do
  @moduledoc """
  An email confirmation token in the form of a UUID V4
  
  The ID of the token is the token itself, since UUID V4 is generated
  via cryptographically strong means and has 122 usable bits of secret.
  """
  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset, only: [soft_delete_changeset: 2]
  alias Ecto.Changeset
  alias MoodleNet.Users.{EmailConfirmToken, User, Token}
  alias MoodleNet.Actors.Actor

  @type validity :: { pos_integer(), System.time_unit }

  @default_validity {2, :day}

  standalone_schema "mn_user_email_confirm_token" do
    belongs_to :user, User
    field :expires_at, :utc_datetime
    field :claimed_at, :utc_datetime
    timestamps()
  end

  @spec create_changeset(User.t) :: Changeset.t
  @spec create_changeset(User.t, validity) :: Changeset.t
  @doc """
  Changeset for creating a token from a user and optional validity period
  Validity period is that accepted by `DateTime.add/3`, default: 2 days.
  """
  def create_changeset(user, validity_period \\ @default_validity)
  def create_changeset(%User{id: user_id}, validity) do
    id = Token.random_key_with_id(user_id)
    expires_at = expires_at(validity)

    %EmailConfirmToken{id: id}
    |> Changeset.change(user_id: user_id, expires_at: expires_at)
  end

  def claim_changeset(%EmailConfirmToken{}=token),
    do: soft_delete_changeset(token, :claimed_at)

  defp expires_at({count, unit}) when is_integer(count) and count > 0,
    do: DateTime.add(DateTime.utc_now(), count, unit)

end
