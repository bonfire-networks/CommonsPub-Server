# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.OAuth.Token do
  @moduledoc """
  OAuth token model
  """
  use MoodleNet.Common.Schema
  alias MoodleNet.Users.User
  alias MoodleNet.OAuth.{Authorization, Token}

  alias Ecto.{Changeset, UUID}

  @default_validity 60 * 10 # seconds: this seems short, but it's what alex set it to

  standalone_schema "oauth_tokens" do
    field :refresh_token, UUID
    field :expires_at, :utc_datetime_usec
    belongs_to :user, User
    belongs_to :auth, Authorization
    timestamps()
  end

  def create_changeset(%User{} = user, %Authorization{} = auth, validity \\ @default_validity) do
    user_only_changeset(user, validity)
    |> Changeset.put_assoc(:auth, auth)
  end

  def user_only_changeset(%User{} = user, validity \\ @default_validity) do
    %Token{}
    |> Changeset.cast(%{}, [])
    |> Changeset.put_assoc(:user, user)
    |> Changeset.put_change(:refresh_token, UUID.generate())
    |> Changeset.put_change(:expires_at, expires_at(validity))
  end

  defp expires_at(validity),
    do: DateTime.add(DateTime.utc_now(), validity)

end
