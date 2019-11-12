# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Collections.Collection do
  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset, only: [meta_pointer_constraint: 1, change_public: 1]
  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Communities.Community
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Localisation.Language
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Resources.Resource

  meta_schema "mn_collection" do
    belongs_to :actor, Actor
    belongs_to :creator, User
    belongs_to :community, Community
    belongs_to :primary_language, Language, type: :binary
    has_many :resources, Resource
    field :name, :string
    field :summary, :string
    field :icon, :string
    field :is_public, :boolean, virtual: true
    field :published_at, :utc_datetime_usec
    field :is_disabled, :boolean, virtual: true
    field :disabled_at, :utc_datetime_usec
    field :deleted_at, :utc_datetime_usec
    timestamps(inserted_at: :created_at)
  end

  @create_cast ~w(name content summary icon primary_language_id)a
  @create_required ~w(primary_language_id)a

  @update_cast @create_cast
  @update_required ~w()a

  def create_changeset(%Pointer{id: id} = pointer, community, creator, attrs) do
    Meta.assert_points_to!(pointer, __MODULE__)

    %Collection{}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.change(
      id: id,
      creator_id: creator.id,
      community_id: community.id,
      is_public: true
    )
    |> Changeset.validate_required(@create_required)
    |> change_public()
    |> meta_pointer_constraint()
  end

  def update_changeset(%Collection{} = collection, attrs) do
    collection
    |> Changeset.cast(attrs, @update_cast)
    |> Changeset.validate_required(@update_required)
    |> change_public()
    |> meta_pointer_constraint()
  end
end
