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
  import MoodleNet.Common.Changeset, only: [change_public: 1]
  alias MoodleNet.Common.Like
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

  @required ~w(is_local)a
  @cast @required ++ ~w(canonical_url is_public)a

  def create_changeset(%User{} = liker, %Pointer{} = liked, %{}=fields) do
    %Like{}
    |> Changeset.cast(fields, @cast)
    |> Changeset.change(
      creator_id: liker.id,
      context_id: liked.id,
      is_public: true
    )
    |> Changeset.validate_required(@required)
    |> Changeset.foreign_key_constraint(:creator_id)
    |> Changeset.foreign_key_constraint(:context_id)
    |> common_changeset()
  end

  def update_changeset(%Like{}=like, %{}=fields) do
    like
    |> Changeset.cast(fields, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
  end
end
