# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.EmailToken do
  @moduledoc """
  An email confirmation token in the form of a UUID V4
  
  The ID of the token is the token itself, since UUID V4 is generated
  via cryptographically strong means and has 122 usable bits of secret.
  """
  use Ecto.Schema
  alias Ecto.Changeset
  alias MoodleNet.Users.{EmailToken, LocalUser, Token}
  alias MoodleNet.Actors.Actor

  @default_validity {2, :day}
  
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "mn_local_user_email_token" do
    belongs_to :local_user, LocalUser
    field :expires_at, :utc_datetime
    field :claimed_at, :utc_datetime
    timestamps()
  end

  def create_changeset(local_user, validity_period \\ @validity_period)
  def create_changeset(%LocalUser{id: id}, validity) do
    Changeset.change %EmailToken{},
      id: Token.random_key_with_id(id),
      local_user_id: id,
      expires_at: expires_at(validity)     
  end

  def claim_changeset(%EmailToken{}=token) do
    Changeset.change token,
      claimed_at: DateTime.utc_now()
  end

  defp expires_at({count, unit}) when is_integer(count) and count > 0,
    do: DateTime.add(DateTime.utc_now(), count, unit)

end
