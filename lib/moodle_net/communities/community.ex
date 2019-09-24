# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Communities.Community do
  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset, only: [meta_pointer_constraint: 1, change_public: 1]
  alias Ecto.Changeset
  alias MoodleNet.Communities.Community
  alias MoodleNet.Comments.Thread
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Users.User

  meta_schema "mn_community" do
    belongs_to :creator, User
    belongs_to :primary_language, Language
    field :is_public, :boolean, virtual: true
    field :published_at, :utc_datetime_usec
    field :deleted_at, :utc_datetime_usec
    has_many :collections, Collection
    has_many :flags, Flag
    timestamps()
  end

  @create_cast ~w(creator_id primary_language_id is_public)a
  @create_required @create_cast

  def create_changeset(%Pointer{id: id}=pointer, fields) do
    Meta.assert_points_to!(pointer, __MODULE__)
    %Community{id: id}
    |> Changeset.cast(fields, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> change_public()
    |> meta_pointer_constraint()
  end

  @update_cast ~w(primary_language_id is_public)a
  @update_required ~w()a

  def update_changeset(%Community{}=community, fields) do
    community
    |> Changeset.cast(fields, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> change_public()
    |> meta_pointer_constraint()
  end
end
