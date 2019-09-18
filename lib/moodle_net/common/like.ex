# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common.Like do
  @doc """
  A Like is an indication that an user enjoyed some content or wants
  to find it again later.

  Likes participate in the meta system and must be created from a pointer
  """
  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset, only: [meta_pointer_constraint: 1, change_public: 1]
  alias MoodleNet.Common.Like
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Actors.Actor
  alias Ecto.Changeset

  meta_schema "mn_like" do
    belongs_to :liked, Pointer
    belongs_to :liker, Actor
    field :is_public, :boolean, virtual: true
    field :published_at, :utc_datetime_usec
    field :deleted_at, :utc_datetime_usec
    timestamps()
  end

  @create_cast ~w(liked_id liker_id is_public)a
  @create_required @create_cast

  def create_changeset(%Pointer{id: id}, fields) do
    %Like{id: id}
    |> Changeset.cast(fields, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> Changeset.foreign_key_constraint(:liked_id)
    |> Changeset.foreign_key_constraint(:liker_id)
    |> meta_pointer_constraint()
    |> change_public()
  end

end
