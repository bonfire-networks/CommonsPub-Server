# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Tag.Category do
  use Bonfire.Repo.Schema

  use Pointers.Pointable,
    otp_app: :commons_pub,
    source: "category",
    table_id: "TAGSCANBECATEG0RY0RHASHTAG"

  # use Bonfire.Repo.Schema

  # import Bonfire.Repo.Changeset, only: [change_public: 1, change_disabled: 1]

  alias Ecto.Changeset
  alias CommonsPub.Tag.Category
  # alias CommonsPub.{Repo}

  @type t :: %__MODULE__{}
  @cast ~w(caretaker_id parent_category_id same_as_category_id)a

  pointable_schema do
    # pointable_schema do

    # field(:id, Pointers.ULID, autogenerate: true)

    # eg. Mamals is a parent of Cat
    belongs_to(:parent_category, Category, type: Ecto.ULID)

    # eg. Olive Oil is the same as Huile d'olive
    belongs_to(:same_as_category, Category, type: Ecto.ULID)

    # which community/collection/organisation/etc this category belongs to, if any
    belongs_to(:caretaker, Pointers.Pointer, type: Ecto.ULID)

    # of course, category is usually a taggable
    has_one(:taggable, CommonsPub.Tag.Taggable, foreign_key: :id)

    # Optionally, profile and/or character mixins
    ## stores common fields like name/description
    has_one(:profile, CommonsPub.Profiles.Profile, foreign_key: :id)
    ## allows it to be follow-able and federate activities
    has_one(:character, CommonsPub.Characters.Character, foreign_key: :id)

    belongs_to(:creator, User)

    field(:prefix, :string, virtual: true)
    field(:facet, :string, virtual: true)

    field(:name, :string, virtual: true)
    field(:summary, :string, virtual: true)
    field(:canonical_url, :string, virtual: true)
    field(:preferred_username, :string, virtual: true)

    field(:is_public, :boolean, virtual: true)
    field(:is_disabled, :boolean, virtual: true, default: false)

    field(:published_at, :utc_datetime_usec)
    field(:disabled_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
  end

  def create_changeset(nil, attrs) do
    %Category{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      parent_category_id: parent_category(attrs),
      same_as_category_id: same_as_category(attrs),
      is_public: true
    )
    |> common_changeset()
  end

  def create_changeset(creator, attrs) do
    %Category{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      creator_id: Map.get(creator, :id, nil),
      parent_category_id: parent_category(attrs),
      same_as_category_id: same_as_category(attrs),
      is_public: true
    )
    |> common_changeset()
  end

  defp parent_category(%{parent_category: id}) when is_binary(id) do
    id
  end

  defp parent_category(%{parent_category: %{id: id}}) when is_binary(id) do
    id
  end

  defp parent_category(_) do
    nil
  end

  defp same_as_category(%{same_as_category: same_as_category}) when is_binary(same_as_category) do
    same_as_category
  end

  defp same_as_category(%{same_as_category: %{id: id}}) when is_binary(id) do
    id
  end

  defp same_as_category(_) do
    nil
  end

  def update_changeset(
        %Category{} = category,
        attrs
      ) do
    category
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      parent_category_id: parent_category(attrs),
      same_as_category_id: same_as_category(attrs)
    )
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    # |> Changeset.foreign_key_constraint(:pointer_id, name: :category_pointer_id_fkey)
    # |> change_public()
    # |> change_disabled()
  end

  def context_module, do: CommonsPub.Tag.Categories

  def queries_module, do: CommonsPub.Tag.Category.Queries

  def follow_filters, do: [:default]
end
