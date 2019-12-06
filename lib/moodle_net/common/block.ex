# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.Block do
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset,
    only: [change_public: 1, change_synced_timestamp: 3, change_muted: 1]

  alias Ecto.Changeset
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Users.User

  @type t :: %__MODULE__{}

  table_schema "mn_block" do
    belongs_to(:creator, User)
    belongs_to(:context, Pointer)
    field(:canonical_url, :string)
    field(:is_local, :boolean)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:is_muted, :boolean, virtual: true)
    field(:muted_at, :utc_datetime_usec)
    field(:is_blocked, :boolean, virtual: true)
    field(:blocked_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  @create_cast ~w(canonical_url is_local is_public is_blocked)a
  @required_cast ~w(is_local is_public is_blocked)a

  def create_changeset(%User{id: creator_id}, %{id: context_id}, fields) do
    %__MODULE__{}
    |> Changeset.cast(fields, @create_cast)
    |> Changeset.validate_required(@required_cast)
    |> Changeset.change(
      creator_id: creator_id,
      context_id: context_id,
      is_muted: false,
    )
    |> Changeset.foreign_key_constraint(:creator_id)
    |> Changeset.foreign_key_constraint(:context_id)
    |> common_changeset()
  end

  @update_cast ~w(is_public is_muted is_blocked)a

  def update_changeset(%__MODULE__{} = block, fields) do
    block
    |> Changeset.cast(fields, @update_cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_muted()
    |> change_synced_timestamp(:is_blocked, :blocked_at)
  end

end
