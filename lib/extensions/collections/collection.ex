# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Collections.Collection do
  use CommonsPub.Common.Schema

  import CommonsPub.Common.Changeset, only: [change_public: 1, change_disabled: 1]

  alias Ecto.Changeset
  alias CommonsPub.Collections
  alias CommonsPub.Character
  alias CommonsPub.Communities.Community
  alias CommonsPub.Collections.Collection
  alias CommonsPub.Feeds.Feed
  alias CommonsPub.Resources.Resource
  alias CommonsPub.Users.User
  alias CommonsPub.Uploads.Content

  @type t :: %__MODULE__{}

  table_schema "mn_collection" do
    belongs_to(:actor, Character)
    has_one(:character, CommonsPub.Character, references: :id, foreign_key: :id)

    belongs_to(:creator, User)

    # TODO: replace by context
    belongs_to(:community, Community)

    belongs_to(:context, Pointers.Pointer)

    belongs_to(:inbox_feed, Feed, foreign_key: :inbox_id)
    belongs_to(:outbox_feed, Feed, foreign_key: :outbox_id)
    # belongs_to(:primary_language, Language)
    # because it's keyed by pointer
    field(:follower_count, :any, virtual: true)
    has_many(:resources, Resource)
    field(:name, :string)
    field(:summary, :string)
    belongs_to(:icon, Content)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:is_disabled, :boolean, virtual: true, default: false)
    field(:disabled_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    field(:extra_info, :map)
    timestamps()
  end

  @required ~w(name is_public creator_id)a
  @cast @required ++ ~w(summary icon_id is_disabled inbox_id outbox_id)a

  def create_changeset(
        %User{} = creator,
        %Community{} = community,
        attrs
      ) do
    %Collection{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      creator_id: creator.id,
      # commmunity parent is deprecated in favour of context
      community_id: community.id,
      context_id: community.id,
      is_public: true
    )
    |> Changeset.validate_required(@required)
    |> common_changeset()
  end

  def create_changeset(
        %User{} = creator,
        context,
        attrs
      ) do
    %Collection{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      creator_id: creator.id,
      context_id: context.id,
      is_public: true
    )
    |> Changeset.validate_required(@required)
    |> common_changeset()
  end

  def create_changeset(
        %User{} = creator,
        attrs
      ) do
    %Collection{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      creator_id: creator.id,
      is_public: true
    )
    |> Changeset.validate_required(@required)
    |> common_changeset()
  end

  def update_changeset(%Collection{} = collection, attrs) do
    collection
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_disabled()
  end

  ### behaviour callbacks

  def context_module, do: Collections

  def queries_module, do: Collections.Queries

  def follow_filters, do: [join: :actor, preload: :actor]

  def type, do: :collection
end
