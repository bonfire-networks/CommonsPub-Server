# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Circle do
  use Pointers.Schema

  import MoodleNet.Common.Changeset, only: [change_public: 1, change_disabled: 1]

  alias Ecto.Changeset
  alias Circle
  alias Character
  alias MoodleNet.Feeds.Feed
  alias MoodleNet.Users.User
  alias MoodleNet.Uploads.Content
  alias Pointers.Pointer
  alias MoodleNet.Actors.Actor

  @type t :: %__MODULE__{}

  # C1RC1E0FPE0P1EAND0RC1RC1ES
  pointable_schema("circle", "01EAQ0ENYEFY2DZHATQWZ2AEEQ") do
    
    # belongs_to(:character, Character)

    # joined fields from Character
    field(:name, :string, virtual: true) 
    field(:summary, :string, virtual: true) 
    field(:updated_at, :utc_datetime_usec, virtual: true)
    
    has_one(:actor, Actor) # joined via Character
    
    # joined fields from Actor:
    field(:preferred_username, :string, virtual: true) 
    field(:canonical_url, :string, virtual: true) 
    
    field(:extra_info, :map)
  end

  @cast ~w(extra_info)a

  def create_changeset(
      attrs
    ) do
  %Circle{}
  # |> Changeset.change(
  #   id: Ecto.ULID.generate()
  #   )
  |> common_changeset()
  end

  def update_changeset(%Circle{} = circle, attrs) do
    circle
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
  end


  ### behaviour callbacks

  def context_module, do: Circle.Circles

  def queries_module, do: Circle.Queries

  def follow_filters, do: [:default]

end
