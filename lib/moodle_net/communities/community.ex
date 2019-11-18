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
  alias MoodleNet.Communities.{Community, CommunityFollowerCount}
  alias MoodleNet.Comments.Thread
  alias MoodleNet.Collections.Collection
  # alias MoodleNet.Localisation.Language
  alias MoodleNet.Meta
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Users.User

  meta_schema "mn_community" do
    belongs_to(:actor, Actor)
    belongs_to(:creator, User)
    field(:canonical_url, :string, virtual: true)
    field(:preferred_username, :string, virtual: true)
    # belongs_to(:primary_language, Language)
    field(:name, :string)
    field(:summary, :string)
    field(:icon, :string)
    field(:image, :string)
    field(:is_disabled, :boolean, virtual: true)
    field(:disabled_at, :utc_datetime_usec)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:is_deleted, :boolean, virtual: true)
    field(:deleted_at, :utc_datetime_usec)
    field(:is_local, :boolean, virtual: true)
    has_many(:collections, Collection)
    has_many(:flags, Flag)
    has_one(:follower_count, CommunityFollowerCount)
    timestamps()
  end

  @required ~w(name)a
  @cast @required ++ ~w(is_disabled is_public summary icon image)a

  def create_changeset(%Pointer{id: id} = pointer, %User{} = creator, %Actor{} = actor, fields) do
    Meta.assert_points_to!(pointer, __MODULE__)

    %Community{}
    |> Changeset.cast(fields, @cast)
    |> Changeset.change(
      id: id,
      # communities are currently all public
      is_public: true,
      actor_id: actor.id,
      creator_id: creator.id
    )
    |> Changeset.validate_required(@required)
    |> common_changeset()
  end

  @update_cast ~w(name summary icon image is_disabled is_public)a

  def update_changeset(%Community{} = community, fields) do
    community
    |> Changeset.cast(fields, @cast)
    |> common_changeset()
  end

  def vivify_virtuals(%Community{actor: %Actor{}}=comm) do
    %{ comm |
       canonical_url: comm.actor.canonical_url,
       preferred_username: comm.actor.preferred_username,
       is_public: not is_nil(comm.published_at),
       is_disabled: not is_nil(comm.disabled_at),
       is_deleted: not is_nil(comm.deleted_at),
       is_local: is_nil(comm.actor.peer_id),
    }
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_disabled()
    # |> validate_language_code(:primary_language)
    |> meta_pointer_constraint()
  end
end
