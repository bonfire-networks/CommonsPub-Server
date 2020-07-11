# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Circle do
  use Pointers.Pointable,
    otp_app: :moodle_net,
    source: "circle",
    table_id: "01EAQ0ENYEFY2DZHATQWZ2AEEQ"

  import MoodleNet.Common.Changeset, only: [change_public: 1, change_disabled: 1]

  alias Ecto.Changeset
  alias Circle
  alias Character
  alias Pointers.Pointer
  alias MoodleNet.Actors.Actor

  @type t :: %__MODULE__{}

  # C1RC1E0FPE0P1EAND0RC1RC1ES
  pointable_schema do
    # joined fields from Profile
    field(:name, :string, virtual: true)
    field(:summary, :string, virtual: true)
    field(:updated_at, :utc_datetime_usec, virtual: true)

    # mixins
    has_one(:profile, Profile, foreign_key: :id)
    has_one(:character, Character, foreign_key: :id)

    # joined via Character
    has_one(:actor, Actor, foreign_key: :id)

    # points to the parent Thing of this Character
    belongs_to(:context, Pointer)

    # joined fields from Actor:
    field(:preferred_username, :string, virtual: true)
    field(:canonical_url, :string, virtual: true)

    field(:extra_info, :map)
  end

  @cast ~w(extra_info)a

  def create_changeset(
        %{id: _} = context,
        attrs
      ) do
    %Circle{}
    # |> Changeset.change(
    #   id: Ecto.ULID.generate()
    #   )
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(context_id: context.id)
    |> common_changeset()
  end

  def create_changeset(attrs) do
    %Circle{}
    # |> Changeset.change(
    #   id: Ecto.ULID.generate()
    #   )
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  def update_changeset(%Circle{} = circle, attrs) do
    circle
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_disabled()
  end

  ### behaviour callbacks

  def context_module, do: Circle.Circles

  def queries_module, do: Circle.Queries

  def follow_filters, do: [:default]
end
