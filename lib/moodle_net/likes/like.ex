# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Likes.Like do
  @doc """
  A Like is an indication that an user enjoyed some content or wants
  to find it again later.
  """
  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset, only: [change_public: 1]
  alias MoodleNet.Likes
  alias MoodleNet.Likes.Like
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Users.User
  alias Ecto.Changeset

  table_schema "mn_like" do
    belongs_to :creator, User
    belongs_to :context, Pointer
    field :canonical_url, :string
    field :is_local, :boolean
    field :is_public, :boolean, virtual: true
    field :published_at, :utc_datetime_usec
    field :deleted_at, :utc_datetime_usec
    timestamps()
  end

  @create_required ~w(is_local)a
  @create_cast @create_required ++ ~w(canonical_url is_public)a

  def create_changeset(%User{id: creator_id}, %{id: context_id}, %{}=fields) do
    %Like{}
    |> Changeset.cast(fields, @create_cast)
    |> Changeset.change(
      creator_id: creator_id,
      context_id: context_id,
      is_public: true
    )
    |> Changeset.validate_required(@create_required)
    |> Changeset.foreign_key_constraint(:creator_id)
    |> Changeset.foreign_key_constraint(:context_id)
    |> change_public()
  end

  @update_cast ~w(canonical_url is_public)a

  def update_changeset(%Like{}=like, %{}=fields) do
    like
    |> Changeset.cast(fields, @update_cast)
    |> change_public()
  end

  ### behaviour callbacks

  def context_module, do: Likes

  def queries_module, do: Likes.Queries

  def follow_filters, do: []

end
