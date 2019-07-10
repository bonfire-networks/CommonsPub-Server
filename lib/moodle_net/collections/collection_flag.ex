# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Collections.CollectionFlag do
  use Ecto.Schema
  alias MoodleNet.ActivityPug.Object
  alias Ecto.Changeset

  schema "mn_collection_flags" do
    belongs_to :flagged_object, Object
    belongs_to :flagging_object, Object
    field :reason, :string
    field :open, :boolean, default: true
  end

  @cast_attrs [:flagged_object_id, :flagging_object_id, :reason, :open]
  @required_attrs [:flagged_object_id, :flagging_object_id, :reason]

  @unique_index :mn_collection_flags_once_index

  def changeset(attrs) do
    %__MODULE__{}
    |> Changeset.cast(attrs, @cast_attrs)
    |> Changeset.validate_required(@required_attrs)
    |> Changeset.unique_constraint(:flagging_object_id, name: @unique_index)
  end

end
