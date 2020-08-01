# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Character do
  use Pointers.Mixin,
    otp_app: :moodle_net,
    source: "character"

  import MoodleNet.Common.Changeset, only: [change_public: 1, change_disabled: 1]

  alias Ecto.Changeset
  alias Character
  alias MoodleNet.Actors.Actor
  alias MoodleNet.Feeds.Feed
  alias MoodleNet.Users.User

  # alias MoodleNet.Uploads.Content
  # alias Pointers.Pointer

  @type t :: %__MODULE__{}

  mixin_schema do
    # references the Actor who plays this Character in the fediverse
    belongs_to(:actor, Actor)

    # belongs_to(:context, Pointer) # points to the parent Thing of this Character

    # field(:characteristic_id, Ecto.ULID) # points to the Thing that this Character represents
    # field(:characteristic, :any, virtual: true)
    # belongs_to(:characteristic, Pointer)

    # name for the Thing this character represents (same naming as the singular object module), eg. Organisation, Geolocation, etc
    field(:facet, :string)

    belongs_to(:inbox_feed, Feed, foreign_key: :inbox_id)
    belongs_to(:outbox_feed, Feed, foreign_key: :outbox_id)
    # because it's keyed by pointer
    field(:follower_count, :any, virtual: true)

    belongs_to(:creator, User)

    field(:is_public, :boolean, virtual: true)
    field(:is_disabled, :boolean, virtual: true, default: false)

    field(:published_at, :utc_datetime_usec)
    field(:disabled_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    # timestamps()
  end

  @required ~w(id facet)a
  @cast @required ++ ~w(actor_id is_disabled inbox_id outbox_id)a

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
      # characteristic_id: characteristic_pointer_id(attrs),
      actor_id: actor.id,
      is_public: true
    )
    |> common_changeset()
  end

  # def create_changeset(
  #       %User{} = creator,
  #       # %{id: _} = characteristic,
  #       %Actor{} = actor,
  #       %{id: _} = context,
  #       attrs
  #     ) do
  #   %Character{}
  #   |> Changeset.cast(attrs, @cast)
  #   |> Changeset.validate_required(@required)
  #   |> Changeset.change(
  #     creator_id: creator.id,
  #     # characteristic_id: characteristic_pointer_id(attrs),
  #     context_id: context.id,
  #     actor_id: actor.id,
  #     is_public: true
  #   )
  #   |> common_changeset()
  # end

  def update_changeset(%Character{} = character, attrs) do
    character
    |> Changeset.cast(attrs, @cast)
    # |> Changeset.change(
    #   characteristic_id: characteristic_pointer_id(attrs)
    # )
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_disabled()
  end

  def characteristic_pointer_id(attrs) do
    map_a_grandchild(attrs, :characteristic, :pointer_id, :id)
  end

  # ugly, feel free to replace
  def map_a_grandchild(parent, child, grandchild1, grandchild2) do
    if(Map.has_key?(parent, child)) do
      child_map = Map.get(parent, child)
      # IO.inspect(child_map)
      Map.get(child_map, grandchild1, Map.get(child_map, grandchild2, nil))
    end
  end
end
