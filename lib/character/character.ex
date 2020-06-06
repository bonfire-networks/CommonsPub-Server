# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Character do
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset, only: [change_public: 1, change_disabled: 1]

  alias Ecto.Changeset
  alias Character
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Feeds.Feed
  alias MoodleNet.Users.User
  alias MoodleNet.Uploads.Content
  alias MoodleNet.Meta.Pointer

  @type t :: %__MODULE__{}

  table_schema "mn_character" do
    belongs_to(:actor, Actor) # references the Actor who plays this Character in the fediverse
    belongs_to(:context, Pointer) # points to the parent Thing of this Character

    field(:characteristic_id, Ecto.ULID) # points to the Thing that this Character represents
    field(:characteristic, :any, virtual: true) 

    field(:facet, :string) # name for the Thing this character represents (same naming as the singular object module), eg. Organisation, Geolocation, etc

    belongs_to(:inbox_feed, Feed, foreign_key: :inbox_id)
    belongs_to(:outbox_feed, Feed, foreign_key: :outbox_id)
    field(:follower_count, :any, virtual: true) # because it's keyed by pointer

    field(:name, :string)
    field(:summary, :string)
    field(:extra_info, :map)

    belongs_to(:icon, Content)
    belongs_to(:image, Content)
    # belongs_to(:primary_language, Language)

    belongs_to(:creator, User)

    field(:is_public, :boolean, virtual: true)
    field(:is_disabled, :boolean, virtual: true, default: false)

    field(:published_at, :utc_datetime_usec)
    field(:disabled_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  @required ~w(name facet)a
  @cast @required ++ ~w(summary extra_info characteristic_id context_id actor_id icon_id is_disabled inbox_id outbox_id)a

  def create_changeset(
      %User{} = creator,
      # %{id: _} = characteristic,
      %Actor{} = actor,
      attrs
    ) do
  %Character{}
  |> Changeset.cast(attrs, @cast)
  |> Changeset.validate_required(@required)
  |> Changeset.change(
    creator_id: creator.id,
    characteristic_id: attrs.characteristic.pointer_id || attrs.characteristic.id,
    actor_id: actor.id,
    is_public: true
  )
  |> common_changeset()
  end

  def create_changeset(
        %User{} = creator,
        # %{id: _} = characteristic,
        %Actor{} = actor,
        %{id: _} = context,
        attrs
      ) do
    %Character{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.change(
      creator_id: creator.id,
      characteristic_id: attrs.characteristic.pointer_id || attrs.characteristic.id,
      context_id: context.id,
      actor_id: actor.id,
      is_public: true
    )
    |> common_changeset()
  end

  def update_changeset(%Character{} = character, attrs) do
    character
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_disabled()
  end
end
