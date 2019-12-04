# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.Follow do
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset, only: [change_public: 1, change_muted: 1]

  alias Ecto.Changeset
  alias MoodleNet.Users.User
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer

  @type t :: %__MODULE__{}

  table_schema "mn_follow" do
    belongs_to(:creator, User)
    belongs_to(:context, Pointer)
    field(:canonical_url, :string)
    field(:is_local, :boolean)
    field(:is_muted, :boolean, virtual: true)
    field(:muted_at, :utc_datetime_usec)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  @required ~w(is_local)a
  @cast @required ++ ~w(canonical_url is_muted is_public)a

  def create_changeset(
        %User{} = follower,
        %Pointer{} = followed,
        fields
      ) do

    %__MODULE__{}
    |> Changeset.cast(fields, @cast)
    |> Changeset.change(
      is_muted: false,
      is_public: true,
      creator_id: follower.id,
      context_id: followed.id
    )
    |> Changeset.validate_required(@required)
    |> Changeset.foreign_key_constraint(:creator_id)
    |> Changeset.foreign_key_constraint(:context_id)
    |> common_changeset()
  end

  def update_changeset(%__MODULE__{} = follow, fields) do
    follow
    |> Changeset.cast(fields, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_muted()
  end

end
