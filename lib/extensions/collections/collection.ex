# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Collections.Collection do
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset, only: [change_public: 1, change_disabled: 1]

  alias Ecto.Changeset
  alias MoodleNet.Collections
  alias CommonsPub.Character
  alias MoodleNet.Communities.Community
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Feeds.Feed
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Users.User
  alias MoodleNet.Uploads.Content

  @type t :: %__MODULE__{}

  table_schema "mn_collection" do
    belongs_to(:actor, Character)
    belongs_to(:creator, User)
    # TODO: replace by context
    belongs_to(:community, Community)
    belongs_to(:context, Pointers.Pointer)
    belongs_to(:inbox_feed, Feed, foreign_key: :inbox_id)
    belongs_to(:outbox_feed, Feed, foreign_key: :outbox_id)
    # belongs_to(:primary_language, Language)
    # because it's keyed by pointer
    field(:follower_count, :any, virtual: true)
    has_many(:resources, Resource)
    field(:name, :string)
    field(:summary, :string)
    belongs_to(:icon, Content)
    field(:is_public, :boolean, virtual: true)
    field(:published_at, :utc_datetime_usec)
    field(:is_disabled, :boolean, virtual: true, default: false)
    field(:disabled_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    field(:extra_info, :map)
    timestamps()
  end

  @required ~w(name is_public creator_id)a
  @cast @required ++ ~w(summary icon_id is_disabled inbox_id outbox_id)a

  def create_changeset(
        %User{} = creator,
        %Community{} = community,
        %Character{} = actor,
        attrs
      ) do
    %Collection{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      creator_id: creator.id,
      # commmunity parent is deprecated in favour of context
      community_id: community.id,
      context_id: community.id,
      actor_id: actor.id,
      is_public: true
    )
    |> Changeset.validate_required(@required)
    |> common_changeset()
  end

  def create_changeset(
        %User{} = creator,
        context,
        %Character{} = actor,
        attrs
      ) do
    %Collection{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      creator_id: creator.id,
      context_id: context.id,
      actor_id: actor.id,
      is_public: true
    )
    |> Changeset.validate_required(@required)
    |> common_changeset()
  end

  def create_changeset(
        %User{} = creator,
        %Character{} = actor,
        attrs
      ) do
    %Collection{}
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(
      creator_id: creator.id,
      actor_id: actor.id,
      is_public: true
    )
    |> Changeset.validate_required(@required)
    |> common_changeset()
  end

  def update_changeset(%Collection{} = collection, attrs) do
    collection
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_disabled()
  end

  ### behaviour callbacks

  def context_module, do: Collections

  def queries_module, do: Collections.Queries

  def follow_filters, do: [join: :actor, preload: :actor]

  def type, do: :collection
end
