# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Resources.Resource do
  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset, only: [meta_pointer_constraint: 1, change_public: 1]
  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Localisation.Language
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Resources.{Resource, ResourceRevision, ResourceLatestRevision}

  meta_schema "mn_resource" do
    belongs_to(:creator, Actor)
    belongs_to(:collection, Collection)
    belongs_to(:primary_language, Language, type: :binary)
    has_many(:revisions, ResourceRevision)
    has_one(:latest_revision, ResourceLatestRevision)
    has_one(:current, through: [:latest_revision, :revision])
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  @create_cast ~w(creator_id collection_id primary_language_id is_public)a
  @create_required @create_cast

  @spec create_changeset(Pointer.t(), map) :: Changeset.t()
  @doc "Creates a changeset for insertion of a resource with the given pointer and attributes."
  def create_changeset(%Pointer{id: id} = pointer, attrs) do
    Meta.assert_points_to!(pointer, __MODULE__)

    %Resource{id: id}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> meta_pointer_constraint()
    |> change_public()
  end

  @update_cast ~w(primary_language_id is_public)a

  @spec update_changeset(%Resource{}, map) :: Changeset.t()
  @doc "Creates a changeset for updating the resource with the given attributes."
  def update_changeset(%Resource{} = resource, attrs) do
    resource
    |> Changeset.cast(attrs, @update_cast)
    |> meta_pointer_constraint()
    |> change_public()
  end
end
