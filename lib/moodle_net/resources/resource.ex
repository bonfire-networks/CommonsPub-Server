# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Resources.Resource do
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset,
    only: [meta_pointer_constraint: 1, change_public: 1, change_disabled: 1, validate_http_url: 2]

  alias Ecto.Changeset
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Localisation.Language
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Users.User

  meta_schema "mn_resource" do
    belongs_to(:creator, User)
    belongs_to(:collection, Collection)
    belongs_to(:primary_language, Language, type: :binary)
    field(:canonical_url, :string)
    field(:name, :string)
    field(:summary, :string)
    field(:url, :string)
    field(:license, :string)
    field(:icon, :string)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:is_disabled, :boolean, virtual: true)
    field(:disabled_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps(inserted_at: :created_at)
  end

  @create_required ~w(canonical_url name summary url license icon is_public is_disabled)a
  @create_cast @create_required ++ ~w(primary_language_id)a

  @spec create_changeset(Pointer.t(), Collection.t(), User.t(), map) :: Changeset.t()
  @doc "Creates a changeset for insertion of a resource with the given pointer and attributes."
  def create_changeset(%Pointer{id: id} = pointer, collection, creator, attrs) do
    Meta.assert_points_to!(pointer, __MODULE__)

    %Resource{}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> Changeset.change(
      id: id,
      collection_id: collection.id,
      creator_id: creator.id,
      is_public: true
    )
    |> common_changeset()
  end

  @update_cast ~w(canonical_url name summary url license icon is_public primary_language_id)a

  @spec update_changeset(%Resource{}, map) :: Changeset.t()
  @doc "Creates a changeset for updating the resource with the given attributes."
  def update_changeset(%Resource{} = resource, attrs) do
    resource
    |> Changeset.cast(attrs, @update_cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_disabled()
    |> change_public()
    |> validate_http_url(:url)
    |> meta_pointer_constraint()
  end
end
