# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.Block do
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset,
    only: [change_public: 1, change_synced_timestamp: 3, change_muted: 1]

  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Meta.Pointer

  @type t :: %__MODULE__{}

  standalone_schema "mn_block" do
    belongs_to(:blocker, User)
    belongs_to(:blocked, Pointer)
    field(:canonical_url, :string)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:is_muted, :boolean, virtual: true)
    field(:muted_at, :utc_datetime_usec)
    field(:is_blocked, :boolean, virtual: true)
    field(:blocked_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps(inserted_at: :created_at)
  end

  @create_cast ~w(is_public is_muted is_blocked)a
  @required_cast @create_cast

  def create_changeset(%Actor{} = blocker, %Pointer{} = blocked, fields) do
    %__MODULE__{}
    |> Changeset.cast(fields, @create_cast)
    |> Changeset.validate_required(@required_cast)
    |> Changeset.put_assoc(:blocker, blocker)
    |> Changeset.put_assoc(:blocked, blocked)
    |> change_public()
    |> change_muted()
    |> change_blocked()
  end

  @update_cast ~w(is_public is_muted is_blocked)a

  def update_changeset(%__MODULE__{} = block, fields) do
    block
    |> Changeset.cast(fields, @update_cast)
    |> change_public()
    |> change_muted()
    |> change_blocked()
  end

  def change_blocked(%Changeset{} = changeset),
    do: change_synced_timestamp(changeset, :is_blocked, :blocked_at)
end
