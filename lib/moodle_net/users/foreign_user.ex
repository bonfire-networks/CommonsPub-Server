# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.RemoteUser do
  @moduledoc """
  User model
  """
  use Ecto.Schema
  alias Ecto.Changeset
  alias MoodleNet.Users.{User, RemoteUser}

  schema "mn_remote_users" do
    belongs_to :user, User
    timestamps()
  end

  @cast_attrs ~w(user_id)a
  @required_attrs @cast_attrs

  def changeset(%User{}=user, attrs) do
    user
    |> Changeset.cast(attrs, @cast_attrs)
    |> Changeset.validate_required(@required_attrs)
    |> Changeset.unique_constraint(:user_id)
  end

end
