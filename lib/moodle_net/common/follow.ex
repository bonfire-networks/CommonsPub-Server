# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.Follow do
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset, only: [change_public: 1, change_muted: 1]

  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Meta.Pointer

  @type t :: %__MODULE__{}

  standalone_schema "mn_follow" do
    belongs_to(:follower, Actor)
    belongs_to(:followed, Pointer)
    field(:is_muted, :boolean, virtual: true)
    field(:muted_at, :utc_datetime_usec)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  @create_cast ~w(is_muted is_public)a
  @create_required @create_cast

  def create_changeset(%Actor{} = follower, %Pointer{} = followed, fields) do
    %__MODULE__{}
    |> Changeset.cast(fields, @create_cast)
    |> Changeset.change(
      is_muted: false,
      is_public: true,
      follower_id: follower.id,
      followed_id: followed.id
    )
    |> Changeset.validate_required(@create_required)
    |> change_public()
    |> change_muted()
  end

  @update_cast ~w(is_muted is_public)a

  def update_changeset(%__MODULE__{} = follow, fields) do
    follow
    |> Changeset.cast(fields, @update_cast)
    |> change_public()
    |> change_muted()
  end
end
