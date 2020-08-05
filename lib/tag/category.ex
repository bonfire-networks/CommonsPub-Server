# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Tag.Category do
  use Pointers.Pointable,
    otp_app: :moodle_net,
    source: "category",
    table_id: "TAGSCANBECATEG0RY0RHASHTAG"

  # use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset, only: [change_public: 1, change_disabled: 1]

  alias Ecto.Changeset
  alias CommonsPub.Tag.Category
  alias MoodleNet.{Repo}

  @type t :: %__MODULE__{}
  @cast ~w(caretaker_id parent_category_id same_as_category_id)a

  pointable_schema do
    # pointable_schema do

    # field(:id, Pointers.ULID, autogenerate: true)

    # eg. Mamals is a parent of Cat
    belongs_to(:parent_category, Category, type: Ecto.ULID)

    # eg. Olive Oil is the same as Huile d'olive
    belongs_to(:same_as_category, Category, type: Ecto.ULID)

    # optionally where it came from in the taxonomy
    # belongs_to(:taxonomy_category, Taxonomy.TaxonomyCategory, type: :integer)

    # which community/collection/organisation/etc this category belongs to, if any
    belongs_to(:caretaker, Pointers.Pointer, type: Ecto.ULID)

    # of course, Category is usually a Taggable
    has_one(:taggable, CommonsPub.Tag.Taggable, foreign_key: :id)

    # Optionally, Profile and.or Character mixins
    ## stores common fields like name/description
    has_one(:profile, Profile, foreign_key: :id)
    ## allows it to be follow-able and federate activities
    has_one(:character, Character, foreign_key: :id)

    field(:prefix, :string, virtual: true)
    field(:facet, :string, virtual: true)

    field(:name, :string, virtual: true)
    field(:summary, :string, virtual: true)
    field(:canonical_url, :string, virtual: true)
    field(:preferred_username, :string, virtual: true)
  end

  def create_changeset(attrs) do
    %Category{}
    # |> Changeset.change(id: Ecto.ULID.generate())
    |> Changeset.cast(attrs, @cast)
    # |> Changeset.change(
    #   id: Ecto.ULID.generate()
    #   )
    |> common_changeset()
  end

  def update_changeset(
        %Category{} = category,
        attrs
      ) do
    category
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    # |> Changeset.foreign_key_constraint(:pointer_id, name: :category_pointer_id_fkey)
    # |> change_public()
    # |> change_disabled()
  end

  def context_module, do: CommonsPub.Category.Categories

  def queries_module, do: CommonsPubs.Category.Queries

  def follow_filters, do: [:default]
end
