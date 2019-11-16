# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.Flag do
  @moduledoc """
  A flag is a report that something is breaking the rules

  Flags participate in the meta system and must be created from a pointer
  """
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset,
    only: [meta_pointer_constraint: 1, change_synced_timestamp: 3]

  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Communities.Community
  alias MoodleNet.Users.User
  alias Ecto.Changeset

  meta_schema "mn_flag" do
    belongs_to(:flagger, User)
    belongs_to(:flagged, Pointer)
    belongs_to(:community, Community)
    field(:canonical_url, :string)
    field(:message, :string)
    field(:is_local, :boolean)
    field(:is_resolved, :boolean, virtual: true)
    field(:resolved_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  @cast ~w(canonical_url message is_local is_resolved)a
  @required @cast

  def create_changeset(%Pointer{id: id}, %User{} = flagger, %Pointer{} = flagged, attrs) do
    %__MODULE__{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.change(
      id: id,
      flagger_id: flagger.id,
      flagged_id: flagged.id
    )
    |> Changeset.foreign_key_constraint(:flagged_id)
    |> Changeset.foreign_key_constraint(:flagger_id)
    |> change_synced_timestamp(:is_resolved, :resolved_at)
    |> meta_pointer_constraint()
  end

  def create_changeset(
        %Pointer{} = pointer,
        %User{} = flagger,
        %Community{} = community,
        %Pointer{} = flagged,
        attrs
      ) do
    create_changeset(pointer, flagger, flagged, attrs)
    |> Changeset.put_change(:community_id, community.id)
    |> Changeset.foreign_key_constraint(:community_id)
  end
end
