# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Tag.Taggable do
  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset, only: [change_public: 1, change_disabled: 1]

  # use Pointers.Pointable,
  #   otp_app: :moodle_net,
  #   source: "tags",
  #   table_id: "TAGSCANBECATEG0RY0RHASHTAG"

  alias Ecto.Changeset
  alias Tag.Taggable
  alias MoodleNet.{Repo}

  @type t :: %__MODULE__{}
  @required ~w(prefix)a
  @cast @required ++ ~w(context_id parent_tag_id same_as_tag_id taxonomy_tag_id)a

  table_schema "tags" do
    # pointable_schema do

    # field(:id, Pointers.ULID, autogenerate: true)

    # eg. @ or + or #
    field(:prefix, :string)

    # eg. Mamals is a parent of Cat
    belongs_to(:parent_tag, Taggable, type: Ecto.ULID)

    # eg. Olive Oil is the same as Huile d'olive
    belongs_to(:same_as_tag, Taggable, type: Ecto.ULID)

    # optionally where it came from in the taxonomy
    belongs_to(:taxonomy_tag, Taxonomy.TaxonomyTag, type: :integer)

    # Optionally, Thing that is taggable (if not using Profile/Character mixins)
    belongs_to(:context, Pointers.Pointer, type: Ecto.ULID)

    # Optionally, a profile and Character (if not using context)
    ## stores common fields like name/description
    has_one(:profile, Profile, foreign_key: :id)
    ## allows it to be follow-able and federate activities
    has_one(:character, Character, foreign_key: :id)

    field(:name, :string, virtual: true)
    field(:summary, :string, virtual: true)

    many_to_many(:things, Pointers.Pointer,
      join_through: "tags_things",
      unique: true,
      join_keys: [tag_id: :id, pointer_id: :id]
      # on_replace: :update
    )
  end

  def create_changeset(attrs, context) do
    %Taggable{}
    # |> Changeset.change(id: Ecto.ULID.generate())
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(context_id: context.id)
    |> common_changeset()
  end

  def create_changeset(attrs) do
    %Taggable{}
    # |> Changeset.change(id: Ecto.ULID.generate())
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
    |> Repo.preload(:things)
    |> Changeset.change()
    # Set the association
    |> Ecto.Changeset.put_assoc(:things, things)
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
