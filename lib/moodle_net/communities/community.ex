# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Communities.Community do
  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset,
    only: [meta_pointer_constraint: 1, change_public: 1, validate_language_code: 2]
  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Common.Flag
  alias MoodleNet.Communities.Community
  alias MoodleNet.Comments.Thread
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Localisation.Language
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer

  meta_schema "mn_community" do
    belongs_to :creator, Actor
    field :actor, :any, virtual: true
    field :is_public, :boolean, virtual: true
    field :published_at, :utc_datetime_usec
    field :deleted_at, :utc_datetime_usec
    has_many :collections, Collection
    has_many :flags, Flag
    timestamps()
  end

  @create_cast ~w()a
  @create_required @create_cast

  def create_changeset(%Pointer{id: id} = pointer, %Actor{}=creator, fields) do
    Meta.assert_points_to!(pointer, __MODULE__)
    %Community{}
    |> Changeset.cast(fields, @create_cast)
    |> Changeset.change(
      id: id,
      is_public: true,        # communities are currently all public
      creator_id: creator.id, # please actually be a user or remote actor
    )
    |> Changeset.validate_required(@create_required)
    |> change_public()
    |> meta_pointer_constraint()
  end

  @update_cast ~w()a
  @update_required ~w()a

  def update_changeset(%Community{} = community, fields) do
    community
    |> Changeset.cast(fields, @update_cast)
    |> Changeset.validate_required(@update_required)
    |> change_public()
    |> meta_pointer_constraint()
  end
end
