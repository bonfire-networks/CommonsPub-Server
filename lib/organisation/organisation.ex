# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Organisation do
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset, only: [change_public: 1, change_disabled: 1]

  alias Ecto.Changeset
  alias Organisation
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Communities.Community
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Feeds.Feed
  alias MoodleNet.Users.User
  alias MoodleNet.Uploads.Content

  @type t :: %__MODULE__{}

  table_schema "mn_organisation" do
    belongs_to(:actor, Actor)
    belongs_to(:creator, User)
    belongs_to(:community, Community)
    belongs_to(:inbox_feed, Feed, foreign_key: :inbox_id)
    belongs_to(:outbox_feed, Feed, foreign_key: :outbox_id)
    # belongs_to(:primary_language, Language)
    field(:follower_count, :any, virtual: true) # because it's keyed by pointer
    has_many(:collections, Collection)
    has_many(:communities, Community)
    has_many(:resources, Resource)
    field(:name, :string)
    field(:summary, :string)
    belongs_to(:icon, Content)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:is_disabled, :boolean, virtual: true, default: false)
    field(:disabled_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  @required ~w(name is_public)a
  @cast @required ++ ~w(summary icon_id is_disabled inbox_id outbox_id)a

  def create_changeset(
      %User{} = creator,
      %Actor{} = actor,
      attrs
    ) do
  %Organisation{}
  |> Changeset.cast(attrs, @cast)
  |> Changeset.validate_required(@required)
  |> Changeset.change(
    creator_id: creator.id,
    actor_id: actor.id,
    is_public: true
  )
  |> common_changeset()
  end

  def create_changeset_with_community(
        %User{} = creator,
        %Community{} = community,
        %Actor{} = actor,
        attrs
      ) do
    %Organisation{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.change(
      creator_id: creator.id,
      community_id: community.id,
      actor_id: actor.id,
      is_public: true
    )
    |> common_changeset()
  end

  def update_changeset(%Organisation{} = organisation, attrs) do
    organisation
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_disabled()
  end
end
