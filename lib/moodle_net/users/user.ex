# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Users.User do
  @moduledoc """
  A user known to the system

  Inserting a user requires having already inserted either a
  local_user or remote_user
  """
  use Ecto.Schema
  alias Ecto.Changeset
  alias MoodleNet.Users.{User, LocalUser, RemoteUser}
  alias MoodleNet.Actors.Actor

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "mn_user" do
    belongs_to :actor, Actor
    belongs_to :local_user, LocalUser
    belongs_to :remote_user, RemoteUser
    timestamps()
  end

  @create_cast ~w(actor_id local_user_id remote_user_id)a
  @create_required @create_cast
  
  def create_changeset(%Actor{id: id}) do
    attrs = %{actor_id: id}
    %User{}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> Changeset.unique_constraint(:actor_id)
  end

end
