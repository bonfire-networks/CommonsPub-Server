# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Taxonomy.Tag do
  use MoodleNet.Common.Schema

  alias Ecto.Changeset
  alias Taxonomy.Tag


  @type t :: %__MODULE__{}
  @required ~w(label)a
  @cast @required ++ ~w(description parent_tag_id pointer_id)a


  @primary_key{:id, :id, autogenerate: true} # primary key is an integer
  schema "taxonomy_tags" do
    # field(:id, :string)
    field(:label, :string)
    field(:description, :string)
    # field(:parent_tag_id, :integer)
    belongs_to(:parent_tag, Tag, type: :id)
    # field(:pointer_id, Ecto.ULID) # optional pointer ID for the tag (only needed once a tage is actually used)
    belongs_to(:pointer, Pointer, references: :pointer_id, type: Ecto.ULID) # optional pointer ID for the tag (only needed once a tage is actually used)
    has_one(:character, Character, references: :pointer_id, foreign_key: :characteristic_id)
  end

  def update_changeset(
      %Tag{} = tag,
      attrs
    ) do
      tag
      |> Changeset.cast(attrs, @cast)
      |> common_changeset()
  end


  defp common_changeset(changeset) do
    changeset
    # |> Changeset.foreign_key_constraint(:pointer_id, name: :taxonomy_tags_pointer_id_fkey)
    # |> change_public()
    # |> change_disabled()
  end


  def context_module, do: Taxonomy.Tags

  def queries_module, do: Taxonomy.Tags.Queries

  def follow_filters, do: [:default]

end
