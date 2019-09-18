# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.Flag do
  @moduledoc """
  A flag is a report that something is breaking the rules

  Flags participate in the meta system and must be created from a pointer
  """
  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset, only: [meta_pointer_constraint: 1]
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Communities.Community
  alias Ecto.Changeset

  meta_schema "mn_flag" do
    belongs_to :flagged, Pointer
    belongs_to :flagger, Actor
    belongs_to :community, Community
    field :deleted_at, :utc_datetime_usec
    field :reason, :string
    timestamps()
  end

  @create_cast ~w(flagged_id flagger_id community_id reason)a
  @create_required ~w(flagged_id flagger_id reason)a

  def create_changeset(%Pointer{id: id}, attrs) do
    %__MODULE__{id: id}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> Changeset.foreign_key_constraint(:flagged_id)
    |> Changeset.foreign_key_constraint(:flagger_id)
    |> Changeset.foreign_key_constraint(:community_id)
    |> meta_pointer_constraint()
  end

end
