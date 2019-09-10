# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.RemoteUser do
  @moduledoc """
  User model
  """
  use Ecto.Schema
  alias Ecto.Changeset
  alias MoodleNet.Instances.Instance
  alias MoodleNet.Users.{User, RemoteUser}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "mn_remote_user" do
    belongs_to :instance, Instance
    has_one :user, User
    timestamps()
  end

  @cast_attrs ~w(instance_id)a
  @required_attrs @cast_attrs

  def changeset(%User{}=user, attrs) do
    user
    |> Changeset.cast(attrs, @cast_attrs)
    |> Changeset.validate_required(@required_attrs)
    |> Changeset.unique_constraint(:user_id)
  end

end
