# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Taxonomy.TaxonomyTag do
  use MoodleNet.Common.Schema

  alias Ecto.Changeset
  alias Taxonomy.TaxonomyTag


  @type t :: %__MODULE__{}
  @required ~w(name)a
  @cast @required ++ ~w(summary parent_tag_id pointer_id)a


  @primary_key{:id, :id, autogenerate: true} # primary key is an integer
  schema "taxonomy_tag" do
    # field(:id, :string)
    field(:name, :string)
    field(:summary, :string)
    # field(:parent_tag_id, :integer)
    belongs_to(:parent_tag, TaxonomyTag, type: :id)

    has_one(:taggable, Tag.Taggable, references: :id, foreign_key: :taxonomy_tag_id)

    # field(:pointer_id, Ecto.ULID) # optional pointer ID for the tag (only needed once a tage is actually used)
    # belongs_to(:pointer, Pointer, references: :pointer_id, type: Ecto.ULID) # optional pointer ID for the tag (only needed once a tage is actually used)
    # has_one(:character, Character, references: :pointer_id, foreign_key: :characteristic_id)
  end

  def update_changeset(
      %TaxonomyTag{} = tag,
      attrs
    ) do
      tag
      |> Changeset.cast(attrs, @cast)
      |> common_changeset()
  end


  defp common_changeset(changeset) do
    changeset
    # |> Changeset.foreign_key_constraint(:pointer_id, name: :taxonomy_tag_pointer_id_fkey)
    # |> change_public()
    # |> change_disabled()
  end


  def context_module, do: Taxonomy.TaxonomyTags

  def queries_module, do: Taxonomy.TaxonomyTag.Queries

  def follow_filters, do: [:default]

end
