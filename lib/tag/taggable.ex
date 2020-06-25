# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Tag.Taggable do
  use Pointers.Schema

  alias Ecto.Changeset
  alias Tag.Taggable

  @type t :: %__MODULE__{}
  @required ~w(prefix)a
  @cast @required ++ ~w(context_id parent_tag_id same_as_tag_id taxonomy_tag_id)a

  pointable_schema("tags", "TAGSCANBECATEG0RY0RHASHTAG") do
    # eg. @ or + or #
    field(:prefix, :string)

    # eg. community who curates this tag
    belongs_to(:context, Pointers.Pointer, type: Ecto.ULID)
    # eg. Mamals is a parent of Cat
    belongs_to(:parent_tag, Taggable, type: Ecto.ULID)
    # eg. Olive Oil is the same as Huile d'olive
    belongs_to(:same_as_tag, Taggable, type: Ecto.ULID)

    # optionally where it came from in the taxonomy
    belongs_to(:taxonomy_tag, Taxonomy.TaxonomyTag, type: :integer)

    # stores common fields like name/description
    has_one(:profile, Profile, foreign_key: :id)
    # allows it to be follow-able and federate activities
    has_one(:character, Character, foreign_key: :id)

    field(:name, :string, virtual: true)
    field(:summary, :string, virtual: true)

    many_to_many(:things, Pointers.Pointer, join_through: "tags_things", unique: true)
  end

  def create_changeset(attrs) do
    %Taggable{}
    |> Changeset.cast(attrs, @cast)
    # |> Changeset.change(
    #   id: Ecto.ULID.generate()
    #   )
    |> common_changeset()
  end

  def tag_things_changeset(
        %Taggable{} = tag,
        things
      ) do
    tag
    # Set the association
    |> Ecto.Changeset.put_assoc(:things, [things])
    |> common_changeset()
  end

  def update_changeset(
        %Taggable{} = tag,
        attrs
      ) do
    tag
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    # |> Changeset.foreign_key_constraint(:pointer_id, name: :tag_pointer_id_fkey)
    # |> change_public()
    # |> change_disabled()
  end

  def context_module, do: Tag.Taggables

  def queries_module, do: Tag.Taggable.Queries

  def follow_filters, do: [:default]
end
