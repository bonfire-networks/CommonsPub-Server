# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Communities.Community do
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset,
    only: [
      meta_pointer_constraint: 1,
      change_public: 1,
      change_disabled: 1,
      validate_language_code: 2
    ]

  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Common.Flag
  alias MoodleNet.Communities.Community
  alias MoodleNet.Comments.Thread
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Localisation.Language
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Users.User

  meta_schema "mn_community" do
    belongs_to(:actor, Actor)
    belongs_to(:creator, User)
    belongs_to(:primary_language, Language)
    field(:name, :string)
    field(:summary, :string)
    field(:icon, :string)
    field(:image, :string)
    field(:is_disabled, :boolean, virtual: true)
    field(:disabled_at, :utc_datetime_usec)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    has_many(:collections, Collection)
    has_many(:flags, Flag)
    timestamps(inserted_at: :created_at)
  end

  @create_required ~w(name summary icon image is_disabled is_public)a
  @create_cast @create_required ++ ~w(primary_language_id)a

  def create_changeset(%Pointer{id: id} = pointer, %User{} = creator, %Actor{} = actor, fields) do
    Meta.assert_points_to!(pointer, __MODULE__)

    %Community{}
    |> Changeset.cast(fields, @create_cast)
    |> Changeset.change(
      id: id,
      # communities are currently all public
      is_public: true,
      actor_id: actor.id,
      creator_id: creator.id
    )
    |> Changeset.validate_required(@create_required)
    |> common_changeset()
  end

  @update_cast ~w(name summary icon image is_disabled is_public)a

  def update_changeset(%Community{} = community, fields) do
    community
    |> Changeset.cast(fields, @update_cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_disabled()
    |> validate_language_code(:primary_language)
    |> meta_pointer_constraint()
  end
end
